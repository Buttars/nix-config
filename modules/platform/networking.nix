{
  aegix.networking = {
    nixos.networking = {
      nftables.enable = true;
      wireguard.enable = true;
      firewall.trustedInterfaces = [
        "virbr0"
        "podman0"
        "docker0"
      ];
    };
  };
}
