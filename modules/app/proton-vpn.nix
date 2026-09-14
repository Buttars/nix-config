{ __findFile, ... }:
{
  aegix.proton-vpn = {
    includes = [ <aegix/secret-service> ];

    nixos =
      { pkgs, ... }:
      {
        networking.networkmanager = {
          enable = true;
          plugins = [ pkgs.networkmanager-openvpn ];
        };
      };

    homeManager =
      { lib, pkgs, ... }:
      lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        home.packages = [ pkgs.proton-vpn ];
      };
  };
}
