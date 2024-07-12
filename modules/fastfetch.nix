{ config, pkgs, lib, ... }:
let
  cfg = config.hostConfig.modules.fastfetch;
in
{
  options.hostConfig.modules.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch shell";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fastfetch
    ];
  };
}
