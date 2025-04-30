{ lib, config, pkgs, ... }:
let
  containerName = "home-assistant";
  mountPath = "/srv/services/${containerName}";
  mountUnit = builtins.replaceStrings [ "/" "-" "." ] [ "\\x2f" "\\x2d" "\\x2e" ] mountPath + ".mount";
  defaultNfsOptions = [ "defaults" "noatime" "nfsvers=4" "hard" "timeo=600" "auto" "_netdev" "nofail" ];
in
{
  options.home-assistant.enable = lib.mkEnableOption "Home Assistant container with NFS mount";

  options.home-assistant.nfsAddress = lib.mkOption {
    type = lib.types.str;
    description = "The address of the NFS server.";
    apply = v: assert v != null; v;
  };

  options.home-assistant.nfsExposedPath = lib.mkOption {
    type = lib.types.str;
    example = "/mnt/veritas/cognito/services/home-assistant";
    description = "The address of the NFS server.";
    apply = v: assert v != null; v;
  };

  config = lib.mkIf config.home-assistant.enable {
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

    systemd.services."oci-${containerName}" = {
      after = [ "network-online.target" mountUnit ];
      requires = [ mountUnit ];
    };

  };
}
