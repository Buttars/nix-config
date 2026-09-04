{ inputs, __findFile, ... }:
{
  flake-file.inputs = {
    swarmui = {
      url = "github:mcmonkeyprojects/SwarmUI";
      flake = false;
    };
  };

  aegix.swarmui = {
    includes = [ <aegix/luks-volumes> ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        src = inputs.swarmui;
        tag = "swarmui:${src.shortRev or "dev"}";
        stateDir = "/var/lib/swarmui";
      in
      lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        # The layer rules stop an app from pulling in another app, so the host
        # has to bring docker itself.
        assertions = [
          {
            assertion = config.virtualisation.docker.enable;
            message = "swarmui needs docker; include the docker aspect on this host.";
          }
        ];

        # Upstream publishes no image and their Dockerfile installs apt packages,
        # so this cannot be a derivation. Pinning the source as a flake input
        # still ties one image to one revision.
        systemd.services.swarmui-image = {
          description = "Build the SwarmUI container image";
          wantedBy = [ "multi-user.target" ];
          after = [
            "docker.service"
            "network-online.target"
          ];
          wants = [ "network-online.target" ];
          requires = [ "docker.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [ pkgs.docker ];
          script = ''
            if docker image inspect ${tag} >/dev/null 2>&1; then
              exit 0
            fi
            docker build -t ${tag} -f ${src}/launchtools/StandardDockerfile.docker ${src}
          '';
        };

        virtualisation.oci-containers.backend = lib.mkDefault "docker";
        virtualisation.oci-containers.containers.swarmui = {
          image = tag;
          pull = "never";
          ports = [ "7801:7801" ];
          # The entrypoint refuses to start as a non-root user whose uid does not
          # already own the data, so let it run as root and own its own volume.
          volumes = [
            "${stateDir}/Data:/SwarmUI/Data"
            "${stateDir}/Models:/SwarmUI/Models"
            "${stateDir}/Output:/SwarmUI/Output"
            "${stateDir}/dlbackend:/SwarmUI/dlbackend"
          ];
          extraOptions = [ "--device=nvidia.com/gpu=0" ];
        };

        systemd.services.docker-swarmui = {
          after = [ "swarmui-image.service" ];
          requires = [ "swarmui-image.service" ];
        };

        aegix.luks-volumes.swarmui = {
          mountPoint = stateDir;
          size = "100G";
          services = [ "docker-swarmui" ];
        };
      };
  };
}
