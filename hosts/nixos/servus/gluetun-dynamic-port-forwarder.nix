{ config, pkgs, ... }:
let
  containerName = "gluetun";
  portFile = "/run/gluetun/forwarded_port";
  forwardScript = pkgs.writeTextFile {
    name = "gluetun-port-forward";
    destination = "/bin/gluetun-port-forward";
    executable = true;
    text = ''
      #!/bin/sh
      PORT_FILE="${portFile}"
      GLUETUN_CONTAINER_NAME="${containerName}"
      MAX_WAIT=30

      i=0
      while [ $i -lt $MAX_WAIT ]; do
        if [ -s "$PORT_FILE" ]; then
          break
        fi
        echo "Waiting for $PORT_FILE to be populated... ($i/$MAX_WAIT)"
        sleep 1
        i=$((i + 1))
      done

      if [ ! -s "$PORT_FILE" ]; then
        echo "Error: $PORT_FILE not found or empty after $MAX_WAIT seconds." >&2
        exit 1
      fi

      PORT=$(cat "$PORT_FILE")
      GLUETUN_IP=$(${pkgs.podman}/bin/podman inspect -f '{{ .NetworkSettings.IPAddress }}' "$GLUETUN_CONTAINER_NAME")

      if [ -z "$GLUETUN_IP" ]; then
        echo "Error: Failed to get IP of Gluetun container." >&2
        exit 1
      fi

      echo "Forwarding port $PORT from host to Gluetun container at $GLUETUN_IP"
      ${pkgs.socat}/bin/socat TCP-LISTEN:$PORT,fork,reuseaddr TCP:$GLUETUN_IP:$PORT &
    '';
  };

in
{
  systemd.services.gluetun-port-forward = {
    description = "Forward Gluetun VPN port to host";
    wantedBy = [ "multi-user.target" ];
    after = [ "podman-${containerName}.service" ];
    requires = [ "podman-${containerName}.service" ];

    serviceConfig = {
      ExecStart = "${forwardScript}/bin/gluetun-port-forward";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
