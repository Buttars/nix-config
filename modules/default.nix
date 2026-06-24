{
  inputs,
  __findFile,
  lib,
  ...
}:
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.default = {
    includes = [
      <den/define-user>
      <aegix/devenv>
      <aegix/neovim>
      (
        { host, ... }:
        {
          ${host.class}.networking.hostName = host.name;
        }
      )
    ];

    nixos = {
      imports = [
        inputs.srvos.nixosModules.mixins-systemd-boot
        { disabledModules = [ "${inputs.stylix}/modules/kmscon/nixos.nix" ]; }
      ];

      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = with inputs; [
        self.overlays.additions
        self.overlays.modifications
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      documentation.doc.enable = false;
      documentation.info.enable = false;

      programs.git.config = [ { safe.directory = "*"; } ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
      ];
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = [ "all" ];
      system.stateVersion = "25.11";
      time.timeZone = "America/Denver";
      boot.initrd.systemd.enable = true;
    };

    darwin = {
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;

      nixpkgs.overlays = with inputs; [
        darwin.overlays.default
        self.overlays.additions
        self.overlays.modifications
      ];

      nix.enable = false;
      system.stateVersion = 5;
      nixpkgs.config.allowUnfree = true;
    };

    homeManager = {
      imports = [ ./home-manager/dotfiles.nix ];
      programs.home-manager.enable = true;
      home = {
        sessionPath = [ "$HOME/.local/bin" ];
        sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
        stateVersion = "25.11";
      };
    };
  };

  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
