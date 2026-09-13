{ __findFile, lib, ... }:
{
  # Everything a host needs in order to be observed. Vector ships nothing until
  # the host sets aegix.vector.endpoint, so this is safe on a roaming laptop.
  aegix.telemetry = {
    includes = [
      <aegix/node-exporter>
      <aegix/vector>
    ];

    nixos =
      { config, ... }:
      {
        # Container stdout only reaches vector if the runtime hands it to
        # journald. Podman already defaults to journald under systemd.
        virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
          log-driver = "journald";
        };
      };
  };
}
