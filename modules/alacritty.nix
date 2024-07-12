{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.alacritty;
in
{

  options.hostConfig.modules.alacritty = {
    enable = lib.mkEnableOption "Enable Alacritty terminal";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty
    ];
  };

}
