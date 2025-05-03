{ lib, config, pkgs, ... }:
let
  cfg = config.qbittorrent;
  defaultNfsOptions = [ "defaults" "noatime" "nfsvers=4" "hard" "timeo=600" "auto" "_netdev" "nofail" ];
in
{
  options.qbittorrent = {
    enable = lib.mkEnableOption "Enable the qBittorrent container.";

    nfsAddress = lib.mkOption {
      type = lib.types.str;
      description = "Required NFS server address.";
      apply = v: assert v != ""; v;
    };

    nfsExposedPath = lib.mkOption {
      type = lib.types.str;
      description = "Required NFS export path.";
      apply = v: assert v != ""; v;
    };

    gluetun = {
      enable = lib.mkEnableOption "Use network from Gluetun container.";

      containerName = lib.mkOption {
        type = lib.types.str;
        default = "gluetun";
        description = "Name of the external Gluetun container to share network with.";
      };

      qbittorrent-manager = {
        enable = lib.mkEnableOption "Enable gluetun-qbittorrent-port-manager.";

        envFile = lib.mkOption {
          type = lib.types.path;
          description = "Path to decrypted env file for the port manager.";
          apply = v: assert v != null; v;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [

      # Mount
      {
        fileSystems."/srv/services/qbittorrent" = {
          device = "${cfg.nfsAddress}:${cfg.nfsExposedPath}";
          fsType = "nfs";
          options = defaultNfsOptions;
        };
      }

      # Main container
      {
        virtualisation.oci-containers.containers.qbittorrent = {
          image = "lscr.io/linuxserver/qbittorrent:latest";
          volumes = [
            "/srv/services/qbittorrent/downloads:/downloads"
            "/srv/services/qbittorrent/config:/config"
          ];
          environment = {
            PUID = "1000";
            PGID = "1000";
            UMASK = "002";
            TZ = "America/Chicago";
            PERMISSIONS = "false";
          };
          extraOptions = lib.mkMerge [
            (lib.mkIf cfg.gluetun.enable [ "--network=container:${cfg.gluetun.containerName}" ])
            (lib.mkIf (!cfg.gluetun.enable) [
              "--cap-add=CHOWN"
              "--cap-add=SETUID"
              "--cap-add=SETGID"
              "--userns=host"
            ])
          ];
        };
      }

      # Optional port manager
      (lib.mkIf (cfg.gluetun.enable && cfg.gluetun.qbittorrent-manager.enable) {
        virtualisation.oci-containers.containers.gluetun-qbittorrent-port-manager = {
          image = "snoringdragon/gluetun-qbittorrent-port-manager:latest";
          volumes = [
            "/run/gluetun:/tmp/gluetun"
          ];
          environmentFiles = [ cfg.gluetun.qbittorrent-manager.envFile ];
          extraOptions = [ "--network=container:${cfg.gluetun.containerName}" ];
        };
      })

      # Helpful warning
      {
        warnings = lib.mkIf (cfg.gluetun.enable && !(config.virtualisation.oci-containers.containers ? ${cfg.gluetun.containerName})) [
          "qbittorrent.gluetun.enable is true, but no container named '${cfg.gluetun.containerName}' is defined. Make sure to import and enable it."
        ];
      }

      # Mount dependency and partOf groupings
      {
        systemd.services = lib.mkMerge [
          {
            "docker-qbittorrent".after = [ "srv-services-qbittorrent.mount" ];
            "docker-qbittorrent".requires = [ "srv-services-qbittorrent.mount" ];
          }
          (lib.mkIf cfg.gluetun.enable {
            "podman-qbittorrent".partOf = [ "podman-gluetun.service" ];
            "podman-gluetun-qbittorrent-manager".partOf = [ "podman-gluetun.service" ];
          })
        ];
      }

    ]
  );
}
