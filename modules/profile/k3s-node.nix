{ __findFile, ... }:
{
  aegix.k3s-node = {
    includes = [ <aegix/server> ];

    nixos =
      { config, ... }:
      {
        services.k3s = {
          enable = true;
          # The module defaults role to "server"; an agent that omits this
          # silently tries to bring up a second control plane.
          role = "agent";
          serverAddr = "https://k8s-cp.lan:6443";
          tokenFile = config.sops.secrets.k3s-token.path;
        };

        sops.secrets.k3s-token.restartUnits = [ "k3s.service" ];

        networking.firewall = {
          allowedTCPPorts = [ 10250 ];
          allowedUDPPorts = [ 8472 ];
          # nftables is enabled fleet-wide in platform/networking.nix and trusts
          # only virbr0/podman0/docker0, so the CNI interfaces need adding here
          # or the host firewall drops pod traffic.
          trustedInterfaces = [
            "cni0"
            "flannel.1"
          ];
        };
      };
  };
}
