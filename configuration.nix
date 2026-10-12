{ config, pkgs, llm-agents, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # UEFI bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  # DHCP is on by default; your router will assign an IP.

  time.timeZone = "America/New_York";

  # Lets Proxmox see the VM's IP and do clean shutdowns
  services.qemuGuest.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  users.users.bloq = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];          # sudo access
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFTRzdUc4MBuipHrU1Q9PLHafF8e9GrBoWkCZcuJhzVN beringer.owen@gmail.com" ];
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  networking.useDHCP = false;
  networking.interfaces.ens18 = {
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.1.77";
      prefixLength = 24;
    }];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "1.1.1.1" ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "bloq" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    fastfetch
    git
    gh
    curl

    tmux

    # Editors
    neovim
    vim

    # C/C++ toolchain
    gcc
    clang-tools
    cmake
    gnumake
    ninja
    gdb

    postgresql

    # Neovim tools
    ripgrep
    fd
    nodejs
    unzip
    tree-sitter

    claude-code

    #llm-agents.packages.x86_64-linux.herdr
  ];

  system.stateVersion = "26.05";
}
