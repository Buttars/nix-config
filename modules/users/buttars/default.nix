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
      <aegix/cli/tui>
      <aegix/cli/git>
      <aegix/cli/jj>
      <aegix/tmux/full>
      <aegix/hyprland>
      <aegix/browser/brave>
      <aegix/sops>
      <aegix/truenas-mcp-server>
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

        users.mutableUsers = false;
        users.users.buttars.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.buttars.extraGroups = [
          "wheel"
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
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          claude-code
          nvd
          obsidian
          discord
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
