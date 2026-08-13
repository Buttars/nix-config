{ den, __findFile, ... }:
{
  den.aspects.buttars = {
    includes = [
      <den/primary-user>
      (den._.user-shell "fish")
      (<den/unfree> [
        "claude-code"
        "obsidian"
      ])
      <aegix/fish>
      <aegix/fish/aliases>
      <aegix/programming>
      <aegix/terminal-emulator>
      <aegix/neovim>
      <aegix/cli>
      <aegix/archive-tools>
      <aegix/cli/tui>
      <aegix/git>
      <aegix/jj>
      <aegix/herdr>
      <aegix/hyprland>
      <aegix/discord>
      <aegix/thunderbird>
      <aegix/protonmail-bridge>
      <aegix/proton-vpn>
      <aegix/sops>
      <aegix/bitwarden>
      <aegix/printing3d>
      <aegix/reticulum>
      <aegix/theming>
      <aegix/opencode>
      <aegix/battery-notify>
      <aegix/desktop-apps>
      <aegix/mpv>
      <aegix/truenas-mcp-server>
      <aegix/runtime-fetch>
    ];

    nixos =
      { lib, config, ... }:
      {
        programs.nh.enable = true;

        sops.secrets.buttars-password.neededForUsers = true;

        sops.secrets."private_keys/buttars" = {
          owner = "buttars";
          path = "/home/buttars/.ssh/id_ed25519";
          mode = "0600";
        };

        systemd.tmpfiles.rules = [
          "d /home/buttars/.ssh 0700 buttars users -"
          "C /home/buttars/.ssh/id_ed25519.pub 0644 buttars users - ${./keys/id_ed25519.pub}"
        ];

        users.users.buttars.openssh.authorizedKeys.keyFiles = [ ./keys/id_ed25519.pub ];

        security.sudo.wheelNeedsPassword = false;

        users.mutableUsers = false;
        users.users.buttars.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.buttars.extraGroups = [
          "wheel"
          "dialout"
        ]
        ++ lib.attrNames (
          lib.filterAttrs (_: v: v) {
            docker = config.virtualisation.docker.enable;
            libvirtd = config.virtualisation.libvirtd.enable;
            networkmanager = config.networking.networkmanager.enable;
            wireshark = config.programs.wireshark.enable;
            gamemode = config.programs.gamemode.enable;
          }
        );
      };

    homeManager =
      { lib, pkgs, ... }:
      {
        home.packages = with pkgs; [
          nvd
          obsidian
          brave
          claude-code
          vivaldi
        ];
        home.sessionVariables.HERDR_AGENT = "claude";

        aegix.runtime-fetch.entries = [
          {
            name = "conker-live-and-reloaded";
            # Replace with a URL you have the legal right to download from.
            url = "https://REPLACE-ME/conker-live-and-reloaded.iso";
            # Replace with the real `sha256sum` output once you have a source.
            hash = "0000000000000000000000000000000000000000000000000000000000000000";
            dest = "/home/buttars/Games/xbox/Conker Live and Reloaded.iso";
            xiso = true;
          }
          {
            # xemu's official blank/template Xbox HDD image, needed for xemu to
            # boot at all: https://github.com/xqemu/xqemu-hdd-image
            name = "xemu-hdd-template";
            url = "https://github.com/xqemu/xqemu-hdd-image/releases/download/v1.0/xbox_hdd.qcow2.zip";
            hash = "d9f5a4c1224ff24cf9066067bda70cc8b9c874ea22b9c542eb2edbfc4621bb39";
            dest = "/home/buttars/Games/xbox/xbox_hdd.qcow2";
            postFetch = ''${lib.getExe' pkgs.unzip "unzip"} -p "$tmp" xbox_hdd.qcow2 > "$dest"'';
          }
        ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            sentinel = {
              HostName = "sentinel.lan";
              User = "sentinel";
              IdentityFile = "~/.ssh/id_ed25519";
            };
            aegis = {
              HostName = "aegis.lan";
              User = "aegis";
              IdentityFile = "~/.ssh/id_ed25519";
            };
            torrens = {
              HostName = "torrens.lan";
              User = "torrens";
              IdentityFile = "~/.ssh/id_ed25519";
            };
            theatrum = {
              HostName = "theatrum.lan";
              User = "theatrum";
              IdentityFile = "~/.ssh/id_ed25519";
            };
            buttars-desktop = {
              HostName = "buttars-desktop.lan";
              User = "buttars";
              IdentityFile = "~/.ssh/id_ed25519";
            };
          };
        };
      };
  };

}
