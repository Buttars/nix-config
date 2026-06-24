# Reticulum Network Stack aspect.
# Runs rnsd as a system service under a dedicated user.
# Config lives at /var/lib/reticulum/config; edit it to add interfaces
# (LoRa, serial, TCP/UDP peers, etc.) then `systemctl restart reticulum`.
#
# Useful tools installed system-wide:
#   rnsd      – daemon (managed by this service)
#   rnx       – transfer files/data
#   rncp      – copy files between nodes
#   rnsh      – remote shell over Reticulum
#   rnid      – show local identity hashes
#   rnstatus  – show link/path status
#   rnprobe   – probe a destination
#   rnodeconf – configure RNode hardware interfaces
{
  aegix.reticulum.nixos =
    { pkgs, lib, ... }:
    {
      environment.systemPackages = [ pkgs.python3Packages.rns ];

      users.users.reticulum = {
        isSystemUser = true;
        group = "reticulum";
        home = "/var/lib/reticulum";
        description = "Reticulum Network Stack daemon user";
      };
      users.groups.reticulum = { };

      systemd.services.reticulum = {
        description = "Reticulum Network Stack";
        documentation = [ "https://reticulum.network/manual/" ];
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.python3Packages.rns}/bin/rnsd --config /var/lib/reticulum";
          User = "reticulum";
          Group = "reticulum";
          StateDirectory = "reticulum";
          StateDirectoryMode = "0750";
          Restart = "on-failure";
          RestartSec = "10s";
          # Basic hardening
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ "/var/lib/reticulum" ];
        };
      };
    };
}
