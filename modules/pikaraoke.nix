{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.pikaraoke;
  python = pkgs.python39;
in
{
  options.host.modules.pikaraoke = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable PiKaraoke installation and service setup.";
    };
    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Automatically start PiKaraoke in full-screen mode on boot.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "pikaraoke";
      description = "User to run the PiKaraoke service.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      python
      ffmpeg_6
      chromium
      chromedriver
    ];

    systemd.user.services.pikaraokeInstall = {
      description = "PiKaraoke Installation Service";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
        User = cfg.user;
      };
      script = ''
        if [ ! -d "$HOME/.venv" ]; then
          ${python.interpreter} -m venv ~/.venv
          source ~/.venv/bin/activate
          pip install --upgrade pip
          pip install pikaraoke
        fi
      '';
    };

    systemd.user.services.pikaraoke = lib.mkIf cfg.autoStart {
      description = "Run PiKaraoke in Full-Screen Mode";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        #Environment = "PATH=${pkgs.ffmpeg_6}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.chromium}/bin";
        Environment = "PATH=${pkgs.ffmpeg_6}/bin:${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.chromium}/bin:${pkgs.chromedriver}/bin";

        # ProtectSystem = "off";
        ProtectHome = "no";
        # NoNewPrivileges = false;
      };
      script = ''
        source ~/.venv/bin/activate
        #pikaraoke --headless -l 10 &
        pikaraoke
        sleep 5
        #chromium --enable-features=UseOzonePlatform --ozone-platform=wayland --kiosk http://localhost:5555/splash?confirm=false
      '';
    };
  };
}
