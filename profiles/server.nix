{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.server;
in
{
  options.host.profiles.server = {
    enable = lib.mkEnableOption "Enable server profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      delta
      ripgrep
    ];
  };
}
