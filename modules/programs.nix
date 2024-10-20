{ config, lib, ... }:
let
  cfg = config.host;
in
{
  options.host = {
    packages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "List of packages to add to systemPackages";
    };
  };

  config = lib.mkIf (cfg.packages != [ ]) {
    environment.systemPackages = lib.mkMerge [
      config.environment.systemPackages
      cfg.packages
    ];
  };
}
