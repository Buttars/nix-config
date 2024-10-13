{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.zsa;
in
{
  options.hostConfig.profiles.zsa = {
    enable = lib.mkEnableOption "Enable zsa profile";
  };

  config = lib.mkIf cfg.enable {
    

    hardware.keyboard.zsa.enable = true;

    environment.systemPackages = with pkgs; [
      wally-cli
    ];
  };

}
