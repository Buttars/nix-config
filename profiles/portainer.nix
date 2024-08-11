{ config, lib, ... }:
let
  cfg = config.hostConfig.profiles.portainer;
in
{


  options.hostConfig.profiles.portainer = {
    enable = lib.mkEnableOption "Enable containerized portainer service";
    pathToData = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "/home/portainer/portainer/data";
      description = "Path to portainer data. Will be mounted to /data in the container.";
    };
  };

  config = lib.mkMerge [
    {
      virtualisation.podman.enable = true;
    }

    (lib.mkIf
      cfg.enable
      {
        assertions = [
          {
            assertion = cfg.pathToData != "";
            message = "portainer data path is required!";
          }
        ];


        virtualisation.oci-containers = {
          containers = {
            portainer = {
              image = "portainer/portainer-ce:latest";
              extraOptions = [
                # "--restart unless-stopped"
                # "--name portainer"
              ];
              ports = [
                "8000:8000"
                "9000:9000"
              ];
              volumes = [
                "/var/run/docker.sock:/var/run/docker.sock"
                #"/path/to/your/data:/data"
                "${cfg.pathToData}:/data"
              ];
            };
          };
        };

      })
  ];

}
