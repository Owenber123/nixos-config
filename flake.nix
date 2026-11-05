{
  description = "bloq's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    llm-agents.url = "github:numtide/llm-agents.nix";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, llm-agents, deploy-rs, sops-nix, ... }:
    let
      system = "x86_64-linux";
      inherit (nixpkgs) lib;

      # Every machine: the role it plays and the address deploy-rs reaches it on.
      # Adding a host is one line here plus a hosts/<name>/ directory.
      hosts = {
        dev1 = { role = "dev"; address = "192.168.1.77"; };
        # TODO: replace these placeholder addresses with each machine's real IP or DNS name.
        dev2 = { role = "dev"; address = "dev2"; };
        prod1 = { role = "prod"; address = "prod1"; };
        prod2 = { role = "prod"; address = "prod2"; };
      };

      mkSystem = { name, role, hostModules }: lib.nixosSystem {
        inherit system;
        specialArgs = { inherit llm-agents; };
        modules = [
          sops-nix.nixosModules.sops
          ./modules/common.nix
          ./roles/${role}.nix
          { networking.hostName = lib.mkDefault name; }
        ] ++ hostModules;
      };

      mkHost = name: { role, ... }: mkSystem {
        inherit name role;
        hostModules = [ ./hosts/${name} ];
      };

      # roles/personal.nix has no hosts yet; evaluate it against placeholder
      # hardware so `nix flake check` keeps it importable.
      personalProbe = mkSystem {
        name = "personal-probe";
        role = "personal";
        hostModules = [
          ./hosts/placeholder-hardware.nix
          { system.stateVersion = "26.05"; }
        ];
      };
    in
    {
      nixosConfigurations = lib.mapAttrs mkHost hosts;

      deploy.nodes = lib.mapAttrs (name: { address, ... }: {
        hostname = address;
        sshUser = "bloq";
        # deploy-rs switches to root with sudo on the target.
        user = "root";
        # bloq's sudo asks for a password; deploy-rs prompts for it once per node.
        interactiveSudo = true;
        profiles.system.path =
          deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${name};
      }) hosts;

      checks.${system} = deploy-rs.lib.${system}.deployChecks self.deploy // {
        personal-role-eval = nixpkgs.legacyPackages.${system}.writeText "personal-role-eval"
          (builtins.unsafeDiscardStringContext
            personalProbe.config.system.build.toplevel.drvPath);
      };
    };
}
