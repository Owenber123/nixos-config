# PLACEHOLDER hardware for machines that have not been installed yet.
# It only exists so the flake evaluates. Before deploying to a host, replace
# its hosts/<name>/hardware-configuration.nix with the output of
# `nixos-generate-config --show-hardware-config` run on that machine.
{ lib, ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
