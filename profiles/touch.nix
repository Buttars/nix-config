{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.touch;
in
{
  options.host.profiles.touch = {
    enable = lib.mkEnableOption "Enable touch profile";
  };

  config = lib.mkIf cfg.enable {


    environment.systemPackages = with pkgs; [
      wvkbd
      maliit-keyboard
      maliit-framework
    ];
  };
}
