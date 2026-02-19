{
  inputs,
  __findFile,
  den,
  ...
}:
{
  den.default = {
    includes = [
      <den/define-user>
      <den/home-manager>
      <aegis/devenv>
      (
        { host, ... }:
        {
          ${host.class}.networking.hostName = host.name;
        }
      )
    ];

    nixos = {
      documentation.doc.enable = false;
      documentation.info.enable = false;
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = [ "all" ];
      system.stateVersion = "25.11";
      time.timeZone = "America/Denver";
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      boot.initrd.systemd.enable = true;
    };

    darwin = {
      imports = [
        {
          home-manager.useUserPackages = true;
          home-manager.useGlobalPkgs = true;
          nixpkgs.overlays = with inputs; [
            darwin.overlays.default
            self.overlays.additions
            self.overlays.modifications
          ];
        }
      ];
      nix.enable = false;
      system.stateVersion = 5;
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      programs.home-manager.enable = true;
      home = {
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
        stateVersion = "22.11";
      };
    };
  };

  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake-file.inputs.darwin = {
    url = "github:lnl7/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
