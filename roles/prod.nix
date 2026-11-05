# Production servers: a lean, hardened baseline on top of modules/common.nix.
# No dev toolchain lives here.
{ ... }:

{
  # Key-only SSH.
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
  };

  # Ban IPs that keep failing SSH auth.
  services.fail2ban.enable = true;

  # Only wheel members may run sudo at all.
  security.sudo.execWheelOnly = true;

  # Keep the store from growing without bound.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  # Servers don't need man pages and docs.
  documentation.enable = false;

  # ---------------------------------------------------------------------
  # Services
  # ---------------------------------------------------------------------
  # Production services go here (or in modules/services/<name>.nix imported
  # from here). Open any ports they need with
  # networking.firewall.allowedTCPPorts.
}
