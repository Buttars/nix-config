{ ... }:
{
  aegix.node-exporter.nixos = {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [
        "systemd"
        "processes"
      ];
      # The metrics port is only reachable on the trusted LAN; the scraper on
      # the aggregator host needs to reach every node.
      openFirewall = true;
    };
  };
}
