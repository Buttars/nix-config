{ config, pkgs, lib, ... }:
let
  cfg = config.host.modules.zsh;
in
{
  options.host.modules.zsh = {
    enable = lib.mkEnableOption "Enable zsh shell";
  };


  config = lib.mkIf cfg.enable {
    users.defaultUserShell = pkgs.zsh;
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
    };
  };
}
