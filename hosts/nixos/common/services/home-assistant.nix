{ lib, config, pkgs, ... }:
let
  defaultNfsOptions = [ "defaults" "noatime" "nfsvers=4" "hard" "timeo=600" "auto" "_netdev" "nofail" ];
in
{
  options.home-assistant.nfsAddress = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = "The address of the NFS server.";
    apply = v: assert v != null; v;
  };

  options.home-assistant.nfsExposedPath = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "/mnt/veritas/cognito/services/home-assistant";
    description = "The address of the NFS server.";
    apply = v: assert v != null; v;
  };

  config = {
    fileSystems."/srv/services/home-assistant" = {
      device = "${config.home-assistant.nfsAddress}:${config.home-assistant.nfsExposedPath}";
      fsType = "nfs";
      options = defaultNfsOptions;
    };

    virtualisation.oci-containers.containers.home-assistant = {
      image = "ghcr.io/home-assistant/home-assistant:stable";
      ports = [ ];
      volumes = [
        "/srv/services/home-assistant:/config"
      ];
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
    };

    systemd.services."docker-home-assistant" = {
      after = [ "network-online.target" "srv-services-home\\x2dassistant.mount" ];
      requires = [ "srv-services-home\\x2dassistant.mount" ];
    };

  };
}
