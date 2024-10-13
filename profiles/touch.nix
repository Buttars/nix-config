{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.touch;
in
{
  options.hostConfig.profiles.touch = {
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
