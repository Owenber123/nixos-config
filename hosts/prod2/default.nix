# prod2: hardware not yet known.
{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # networking.hostName defaults to "prod2" (set in flake.nix).
  # TODO: set this machine's network config once its IP is known, e.g.
  #   networking.interfaces.<iface>.ipv4.addresses = [ { address = "..."; prefixLength = 24; } ];
  # and update its address in flake.nix. Until then it uses DHCP.

  system.stateVersion = "26.05";
}
