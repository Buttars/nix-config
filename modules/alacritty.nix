{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.alacritty;
in
{

  options.host.modules.alacritty = {
    enable = lib.mkEnableOption "Enable Alacritty terminal";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      alacritty
    ];
  };

}
