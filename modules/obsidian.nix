{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.obsidian;
in
{
  options.hostConfig.modules.obsidian = {
    enable = lib.mkEnableOption "Enable Obsidian";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  };
}
