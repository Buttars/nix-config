{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.tui-task-manager;
in
{
  options.hostConfig.profiles.tui-task-manager = {
    enable = lib.mkEnableOption "Enable tui-task-manager profile";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      taskwarrior3
    ];
  };
}
