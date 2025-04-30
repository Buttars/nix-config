{ lib, config, pkgs, ... }:
let
  defaultNfsOptions = [ "defaults" "noatime" "nfsvers=4" "hard" "timeo=600" "auto" "_netdev" "nofail" ];
in
{
  options.qbittorrent.enable = lib.mkEnableOption "qBittorrent container with NFS-mount-backed data and config";

  options.qbittorrent.nfsAddress = lib.mkOption {
    type = lib.types.str;
    example = "10.0.0.4";
    description = "NFS server address.";
  };

  options.qbittorrent.nfsExposedPath = lib.mkOption {
    type = lib.types.str;
    example = "/mnt/veritas/cognito/services/qbittorrent";
    description = "NFS export path for qBittorrent data and config.";
  };

  config = lib.mkIf config.qbittorrent.enable {
    # Mount NFS share
    fileSystems."/srv/services/qbittorrent" = {
      device = "${config.qbittorrent.nfsAddress}:${config.qbittorrent.nfsExposedPath}";
      fsType = "nfs";
      options = defaultNfsOptions;
    };

    # OCI container for qBittorrent
    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      ports = [
        "8080:8080/tcp" # Web UI
        "6881:6881/tcp" # BitTorrent TCP
        "6881:6881/udp" # BitTorrent UDP
      ];
      volumes = [
        "/srv/services/qbittorrent/downloads:/downloads"
        "/srv/services/qbittorrent/config:/config"
      ];
      environment = {
        PUID = "1000"; # Replace with your user’s UID
        PGID = "1000"; # Replace with your user’s GID
        UMASK = "002";
        TZ = "America/Chicago";
      };
      extraOptions = [
        "--cap-drop=ALL"
        "--read-only"
        "--tmpfs=/tmp"
      ];
    };

    # Ensure the container starts only after NFS mount is ready
    systemd.services."docker-qbittorrent".after = [ "srv-services-qbittorrent.mount" ];
    systemd.services."docker-qbittorrent".requires = [ "srv-services-qbittorrent.mount" ];
  };
}
