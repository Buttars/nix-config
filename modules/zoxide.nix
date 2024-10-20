{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.zoxide;
in
{
  options.host.modules.zoxide = {
    enable = lib.mkEnableOption "Enable zoxide";
  };


  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      zoxide
    ];
  };
}
