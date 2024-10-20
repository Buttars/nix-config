{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.obsidian;
in
{
  options.host.modules.obsidian = {
    enable = lib.mkEnableOption "Enable Obsidian note taking app";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  };
}
