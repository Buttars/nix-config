{ pkgs, lib, ... }: {
  host = {
    profiles = {
      audio.enable = true;
    };
    modules = {
      pikaraoke = {
        enable = true;
        autoStart = true;
      };
    };
    packages = with pkgs; [
      # libraspberrypi
      # raspberrypi-eeprom
    ];
  };

  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnsupportedSystem = true;

  # hardware = {
  #   raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  #   hardware.raspberry-pi."4".fkms-3d.enable = true;
  #   deviceTree = {
  #     enable = true;
  #     filter = "*rpi-4-*.dtb";
  #   };
  # };

  console.enable = false;


  networking = {
    hostName = "karaoke";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  services.ntp.enable = true;
  services.automatic-timezoned.enable = true;

  sdImage.compressImage = false;
}
