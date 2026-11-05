# Personal machines: a baseline on top of modules/common.nix.
# No host uses this role yet; flake.nix evaluates it in the
# personal-role-eval check so it stays importable.
{ pkgs, ... }:

{
  # Laptops and desktops move between networks.
  networking.networkmanager.enable = true;
  users.users.bloq.extraGroups = [ "networkmanager" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    fastfetch
    neovim
  ];
}
