{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.modules.docker;
in
{
  options.hostConfig.modules.docker = {
    enable = lib.mkEnableOption "Enable Docker virutalization";
    btrfs = lib.mkEnableOption "Enable btrfs support for docker";
  };


  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.storageDriver = lib.mkIf cfg.btrfs "btrfs";
  };
}
