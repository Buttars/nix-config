{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.tui-file-manager;
in
{
  options.host.profiles.tui-file-manager = {
    enable = lib.mkEnableOption "Enable tui-file-manager profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lf
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
