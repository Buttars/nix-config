{
  den,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.theatrum = {
    users.theatrum = {
      classes = [ "homeManager" ];
      aspect = den.aspects."theatrum-user";
    };
  };

  den.aspects.theatrum-user = {
    includes = [ <den/primary-user> ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ htop ];
      };
  };
  den.aspects.theatrum = {
    includes = [
      <den/define-user>
      (<den/unfree> [
        "nvidia-x11"
        "nvidia-settings"
      ])
      <aegix/networking>
      <aegix/sops>
      <aegix/fail2ban>
      (<aegix/disks/btrfs> {
        disk = "/dev/sda";
        withSwap = true;
        swapSize = "32";
      })
    ];

    nixos =
      { pkgs, config, ... }:
      {

        hardware.facter.reportPath = ./_facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        fileSystems =
          let
            nfsProvider = "truenas.lan";
            nfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=4.2"
              "rsize=262144"
              "wsize=262144"
              "nconnect=4"
              "async"
              "hard"
              "timeo=600"
              "retrans=2"
              "auto"
              "_netdev"
              "nofail"
            ];
            serviceNfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=3"
              "rsize=262144"
              "wsize=262144"
              "nconnect=4"
              "async"
              "hard"
              "timeo=600"
              "retrans=2"
              "auto"
              "_netdev"
              "nofail"
              "nolock"
            ];
          in
          {
            "/srv" = {
              device = "${nfsProvider}:/mnt/veritas/cognito";
              fsType = "nfs";
              options = nfsOptions;
            };
            "/var/lib/jellyfin" = {
              device = "${nfsProvider}:/mnt/veritas/services/jellyfin";
              fsType = "nfs";
              options = serviceNfsOptions;
            };
            "/var/cache/jellyfin" = {
              device = "tmpfs";
              fsType = "tmpfs";
              options = [
                "size=20G"
                "mode=0755"
              ];
            };
          };

        users.users.jellyfin.uid = 998;
        users.groups.jellyfin.gid = 998;

        systemd.services.jellyfin = {
          after = [ "var-lib-jellyfin.mount" ];
          requires = [ "var-lib-jellyfin.mount" ];
        };

        services.jellyfin = {
          enable = true;
          dataDir = "/var/lib/jellyfin/data";
          configDir = "/var/lib/jellyfin/config";
        };

        virtualisation.podman.enable = true;

        networking = {
          defaultGateway = "10.0.40.1";
          nameservers = [ "10.0.40.1" ];
          firewall = {
            enable = true;
            allowedTCPPorts = [
              22
              8096
            ];
            allowedUDPPorts = [ 8096 ];
          };
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          open = false;
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            nvidia-vaapi-driver
          ];
        };

        users.users.jellyfin.extraGroups = [ "video" "render" ];

        systemd.services.jellyfin-cache-monitor = {
          description = "Clear Jellyfin transcode cache when tmpfs is nearly full";
          serviceConfig = {
            Type = "oneshot";
            User = "jellyfin";
          };
          script = ''
            threshold=85
            cache_dir="/var/cache/jellyfin"
            transcode_dir="$cache_dir/transcodes"

            usage=$(${pkgs.coreutils}/bin/df --output=pcent "$cache_dir" | ${pkgs.coreutils}/bin/tail -1 | ${pkgs.gnused}/bin/sed 's/[^0-9]//g')

            echo "jellyfin-cache-monitor: usage=''${usage}% threshold=''${threshold}%"

            if [ -n "$usage" ] && [ "$usage" -ge "$threshold" ]; then
              echo "jellyfin-cache-monitor: threshold reached, clearing transcodes"
              deleted=$(${pkgs.findutils}/bin/find "$transcode_dir" -type f \
                \( -name "*.ts" -o -name "*.m3u8" -o -name "*.mp4" -o -name "*.webm" \) \
                -print -delete | ${pkgs.coreutils}/bin/wc -l)
              echo "jellyfin-cache-monitor: deleted ''${deleted} files"
            else
              echo "jellyfin-cache-monitor: usage within threshold, no action taken"
            fi
          '';
        };

        systemd.timers.jellyfin-cache-monitor = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "*:0/5";
            Persistent = true;
          };
        };

        sops.secrets.buttars-password.neededForUsers = true;

        users.mutableUsers = false;
        users.users.theatrum.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.theatrum.extraGroups = [ "wheel" ];
        users.users.theatrum.createHome = true;
        users.users.theatrum.openssh.authorizedKeys.keyFiles = [ ../../users/buttars/keys/id_ed25519.pub ];
        systemd.tmpfiles.rules = [
          "d /home/theatrum/.ssh 0700 theatrum users -"
        ];

        services.openssh.enable = true;
      };

    homeManager = { };
  };
}
