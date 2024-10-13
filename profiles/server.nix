{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.server;
in
{
  options.hostConfig.profiles.server = {
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
