{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.fastfetch;
in
{
  options.host.modules.fastfetch = {
    enable = lib.mkEnableOption "Enable fastfetch shell";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fastfetch
    ];
  };
}
