{
  den.aspects.sentinel.nixos =
    { config, ... }:
    {
      sops.secrets.attic-server-env = { };

      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.attic-server-env.path;

        settings = {
          listen = "[::]:8081";
          api-endpoint = "http://sentinel.lan:8081/";

          garbage-collection = {
            interval = "1 day";
            default-retention-period = "30 days";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 8081 ];
    };
}
