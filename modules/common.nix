# Settings shared by every machine, whatever its role.
{ lib, pkgs, ... }:

{
  # UEFI bootloader; a host with different firmware overrides these.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  time.timeZone = "America/New_York";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "bloq" ];
  };

  nixpkgs.config.allowUnfree = true;

  users.users.bloq = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];          # sudo access
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTRzdUc4MBuipHrU1Q9PLHafF8e9GrBoWkCZcuJhzVN beringer.owen@gmail.com" ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  # sops-nix decrypts secrets at activation with the host's SSH ed25519 key,
  # converted to an age key. Declare secrets per role or host, e.g.:
  #   sops.secrets."example" = { sopsFile = ../secrets/prod.yaml; };
  # See README.md for setting up keys and .sops.yaml.
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  environment.systemPackages = with pkgs; [
    git
    curl
    tmux
    vim
  ];
}
