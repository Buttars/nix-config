{ config, lib, pkgs, system, ... }:
let
  cfg = config.hostConfig.profiles.tui-file-manager;
in
{
  options.hostConfig.profiles.tui-file-manager = {
    enable = lib.mkEnableOption "Enable tui-file-manager profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lf
      superfile
      feh
      nsxiv
      zathura
      bat
      ueberzug
      file
      mpv
    ];
  };
}
