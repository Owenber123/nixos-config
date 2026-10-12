{
  description = "bloq's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    llm-agents.url = "github:numtide/llm-agents.nix";
    treehouse.url = "github:kunchenguid/treehouse";
  };

  outputs = { self, nixpkgs, llm-agents, treehouse, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit llm-agents treehouse; };
      modules = [ ./configuration.nix ];
    };
  };
}
