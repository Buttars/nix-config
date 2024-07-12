{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.zoxide;
in
{
  options.hostConfig.modules.zoxide = {
    enable = lib.mkEnableOption "Enable zoxide";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zoxide
    ];
  };
}
