{ den, __findFile, ... }:
{
  den.aspects.buttars = {
    nixos =
      { lib, config, ... }:
      {
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
        users.users.buttars.extraGroups = [ "wheel" ] ++ lib.attrNames (lib.filterAttrs (_: v: v) {
          docker = config.virtualisation.docker.enable;
          libvirtd = config.virtualisation.libvirtd.enable;
          networkmanager = config.networking.networkmanager.enable;
          wireshark = config.programs.wireshark.enable;
          gamemode = config.programs.gamemode.enable;
        });
      };

    includes = [
      <den/primary-user>
      (den._.user-shell "fish")
      (<den/unfree> [ "claude-code" ])
      <aegis/programming>
      <aegis/terminal-emulator>
      <aegis/neovim>
      <aegis/cli>
      <aegis/cli/tui>
      <aegis/cli/git>
      <aegis/hyprland>
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ claude-code ];
      };
  };

  den.hosts.x86_64-linux.buttars-laptop.users.buttars.aspect = "buttars";
  den.hosts.x86_64-linux.buttars-desktop.users.buttars.aspect = "buttars";
}
