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
    auto-optimise-store = true;
  };

  # Agents + devshells fill the store fast
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Pairs with discard=on on the Proxmox disk
  services.fstrim.enable = true;

  # Many worktrees × file watchers × test runners
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 8192;
    "fs.file-max" = 2097152;
  };
  security.pam.loginLimits = [
    { domain = "*"; type = "-"; item = "nofile"; value = "1048576"; }
  ];

  # Degrade under memory pressure instead of hard-hanging
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  services.earlyoom.enable = true;

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
