{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.password-management;
in
{
  options.hostConfig.profiles.password-management = {
    enable = lib.mkEnableOption "Enable password management software";
  };

  config = lib.mkIf cfg.enable {
    # TODO: Make this declarative when we can manage secrets.
    environment.systemPackages = with pkgs; [
      syncthing
      keepassxc
      keepmenu
    ];
  };
}
