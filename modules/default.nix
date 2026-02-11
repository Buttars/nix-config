{
  inputs,
  __findFile,
  den,
  ...
}:
let
  stateVersion = "25.11";
in
{
  den.default = {
    includes = [
      <den/define-user>
      <den/home-manager>
      (<den/unfree> ["terraform"])
      (
        { host, ... }:
        {
          ${host.class}.networking.hostName = host.name;
          nixpkgs.config.allowUnfree = 1;
        }
      )
    ];

    nixos = {
      imports = [
        {
          home-manager.extraSpecialArgs = {
            inherit inputs stateVersion;
          };
        }
      ];
      stateVersion = "25.11";
      time.timeZone = "America/Denver";
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      boot.initrd.systemd.enable = true;
    };

    darwin = {
      imports = [
        {
          home-manager.extraSpecialArgs = {
            stateVersion = "25.11";
            inherit inputs;
          };
        }
      ];
      nix.enable = false;
      system.stateVersion = 5;
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      imports = [./home-manager/dotfiles.nix];
      programs.home-manager.enable = true;
      home = {
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
        stateVersion = "25.11";
      };
    };
  };
}
