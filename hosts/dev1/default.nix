# dev1: Proxmox VM (formerly the single `nixos` host).
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Lets Proxmox see the VM's IP and do clean shutdowns
  services.qemuGuest.enable = true;

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

  system.stateVersion = "26.05";
}
