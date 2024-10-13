{ config, lib, pkgs, ... }:
let
  cfg = config.hostConfig.profiles.programming;
in

{
  options.hostConfig.profiles.programming = {
    enable = lib.mkEnableOption "Enable programming profile.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nodejs
      cargo
      gcc
      git
      delta
      nixpkgs-fmt
      gnumake
      ripgrep
      python3
      devpod
      go
      lazydocker
    ] ++
    (pkgs.lib.optionals
      pkgs.stdenv.isLinux
      [ /* julia */ ]);

    programs.direnv.enable = true;
  };
}
