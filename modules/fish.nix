{ lib, config, ... }:
let
  cfg = config.host.modules.fish;
in
{
  options.host.modules.fish = {
    enable = lib.mkEnableOption "Enable fish shell";
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;
  };
}
