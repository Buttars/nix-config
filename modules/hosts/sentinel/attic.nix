{
  den.aspects.sentinel.nixos =
    { config, ... }:
    {
      sops.secrets.attic-server-env = { };

      services.atticd = {
        enable = true;
        environmentFile = config.sops.secrets.attic-server-env.path;

        settings = {
          # 8080 is nextcloud's nginx on this host.
          listen = "[::]:8081";
          api-endpoint = "http://sentinel.lan:8081/";

          # The cache holds nothing secret and lives behind the router, so it
          # is readable by the LAN; pushing still needs a token.
          require-proof-of-possession = false;

          # Attic stores chunks outside the nix store, so <aegix/nix-gc> cannot
          # reach them -- retention is this service's job instead.
          garbage-collection = {
            interval = "1 day";
            default-retention-period = "30 days";
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 8081 ];
    };
}
