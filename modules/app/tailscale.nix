# Tailscale client, pointed at the self-hosted headscale server rather than
# Tailscale's own coordination service. `aegix.headscale` runs the server;
# this is what every fleet member -- including the headscale host itself --
# joins the tailnet with. Every host that includes this must also include
# <aegix/sops> itself (app -> app includes are disallowed, so this cannot
# pull it in for you).
{ __findFile, ... }:
{
  aegix.tailscale.nixos =
    { config, ... }:
    {
      sops.secrets."headscale/authkey" = { };

      services.tailscale = {
        enable = true;
        openFirewall = true;
        authKeyFile = config.sops.secrets."headscale/authkey".path;
        extraUpFlags = [ "--login-server=https://headscale.buttars.dev" ];
      };
    };
}
