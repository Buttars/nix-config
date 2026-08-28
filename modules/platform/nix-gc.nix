{
  aegix.nix-gc = {
    nixos.nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    darwin.launchd.daemons.nix-gc.serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        "/bin/wait4path /nix/var/nix/profiles/default/bin/nix-collect-garbage && exec /nix/var/nix/profiles/default/bin/nix-collect-garbage --delete-older-than 14d"
      ];
      StartCalendarInterval = [
        {
          Weekday = 1;
          Hour = 3;
          Minute = 15;
        }
      ];
      RunAtLoad = false;
      StandardOutPath = "/var/log/nix-gc.log";
      StandardErrorPath = "/var/log/nix-gc.log";
    };
  };
}
