# Reticulum Network Stack aspect.
# nixos: runs rnsd as a system service under a dedicated user.
# Config lives at /var/lib/reticulum/config; edit it to add interfaces
# (LoRa, serial, TCP/UDP peers, etc.) then `systemctl restart reticulum`.
# homeManager: installs client-side tools (rns CLI utilities, MeshChat GUI).
#
# Useful tools installed system-wide (nixos) and for the user (homeManager):
#   rnsd      – daemon (managed by this service, nixos only)
#   rnx       – transfer files/data
#   rncp      – copy files between nodes
#   rnsh      – remote shell over Reticulum
#   rnid      – show local identity hashes
#   rnstatus  – show link/path status
#   rnprobe   – probe a destination
#   rnodeconf – configure RNode hardware interfaces
#   meshchat  – web-based LXMF chat client (homeManager, x86_64-linux only)
{
  aegix.reticulum = {
    homeManager =
      { pkgs, lib, ... }:
      {
        home.packages = [
          pkgs.python3Packages.rns
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          # MeshChat only ships prebuilt Linux binaries for x86_64.
          pkgs.meshchat
        ];
      };

    nixos =
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
  };
}
