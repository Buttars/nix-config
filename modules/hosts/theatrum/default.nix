{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.theatrum = { };
  den.aspects.theatrum = {
    includes = [
      <den/define-user>
      (<den/unfree> [ "nvidia-x11" ])
      <aegis/networking>
      (<aegis/disks/btrfs> {
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

        fileSystems."/srv" =
          let
            nfsProvider = "truenas.lan";
            defaultNfsOptions = [
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
          in
          {
            device = "${nfsProvider}:/mnt/veritas/cognito";
            fsType = "nfs";
            options = defaultNfsOptions;
          };

        fileSystems."/var/cache/jellyfin" = {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "size=2G"
            "mode=0755"
          ];
        };

        services.jellyfin = {
          enable = true;
          dataDir = "/srv/services/jellyfin/data";
          configDir = "/srv/services/jellyfin/config";
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

        hardware.nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          open = false;
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            config.boot.kernelPackages.nvidiaPackages.stable
            nvidia-vaapi-driver
          ];
        };

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

        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
      };

    homeManager = { };
  };
}
