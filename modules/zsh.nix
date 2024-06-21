{ config, pkgs, lib, ... }: let
  cfg = config.hostConfig.modules.zsh;
in {
  options.hostConfig.modules.zsh = {
    enable = lib.mkEnableOption "Enable zsh shell";
  };


  config = lib.mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh = {
      enable = true;
    };
  };
}
