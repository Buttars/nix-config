{ config, lib, pkgs, ... }:
let
  cfg = config.host.modules.docker;
in
{
  options.host.modules.docker = {
    enable = lib.mkEnableOption "Enable Docker virutalization";
    btrfs = lib.mkEnableOption "Enable btrfs support for docker";
  };


  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.docker.storageDriver = lib.mkIf cfg.btrfs "btrfs";
  };
}
