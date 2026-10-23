{
  inputs,
  __findFile,
  lib,
  ...
}:
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.schema.host.includes = [
    <aegix/nix-gc>
    <aegix/deploy>
  ];

  den.default = {
    # <aegix/telemetry> is deliberately absent: node-exporter opens a firewall
    # port, so each host opts in rather than every host exposing metrics.
    includes = [
      <den/define-user>
      <aegix/devenv>
      <aegix/locale>
      <aegix/neovim>
      <aegix/reboot>
      (
        { host, ... }:
        {
          ${host.class}.networking.hostName = host.name;
        }
      )
      (
        { host, ... }:
        let
          # A deploy pushes locally-built paths that no cache has signed, and
          # only a trusted user may add unsigned paths. The Justfile deploys as
          # <host>@<host>.lan, so trust that user where it exists -- hosts
          # without the account need no entry. The interactive accounts carry
          # the same trust so that substituters they configure are not ignored.
          candidates = [
            host.name
            "buttars"
            "landon.buttars"
          ];
          present = config: lib.filter (name: config.users.users ? ${name}) candidates;
        in
        {
          nixos =
            { config, ... }:
            {
              nix.settings.trusted-users = present config;
            };

          darwin =
            { config, ... }:
            {
              # Determinate owns /etc/nix/nix.conf, so nix-darwin writes none and
              # nix.settings is inert; customSettings renders nix.custom.conf,
              # which that file !includes. The key replaces Nix's built-in
              # default instead of extending it, hence root.
              determinateNix.customSettings.trusted-users = [ "root" ] ++ present config;
            };
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
      i18n.supportedLocales = [ "all" ];
      system.stateVersion = "25.11";
      boot.initrd.systemd.enable = true;
    };

    darwin = {
      imports = [ inputs.determinate.darwinModules.default ];

      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;

      nixpkgs.overlays = with inputs; [
        darwin.overlays.default
        self.overlays.additions
        self.overlays.modifications
      ];

      determinateNix.enable = true;
      system.stateVersion = 5;
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };

    homeManager = {
      imports = [ ./_hm-dotfiles.nix ];
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

    # No nixpkgs follows: upstream pins its own nixpkgs and advises against
    # overriding it.
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    srvos = {
      url = "github:nix-community/srvos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
