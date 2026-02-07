{ inputs, __findFile, ... }:
let
  stateVersion = "25.11";
in
{
  den.default = {
    includes = [
      <den/home-manager>
      <den/define-user>
      (
        { host, ... }:
        {
          ${host.class}.networking.hostName = host.name;
        }
      )
    ];

    nixos = {
      stateVersion = "25.11";
      time.timeZone = "America/Denver";
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      boot.initrd.systemd.enable = true;
    };

    darwin = {
      # nix.enable = false;
      system.stateVersion = 5;
    };

    homeManager = {
      programs.home-manager.enable = true;
      home = {
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
        stateVersion = "25.11";
      };
    };
  };
}
