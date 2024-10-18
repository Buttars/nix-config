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
      atac
      cargo
      delta
      devpod
      dig
      gcc
      git
      gnumake
      go
      lazydocker
      nixpkgs-fmt
      nodejs
      python3
      ripgrep
    ] ++
    (pkgs.lib.optionals
      pkgs.stdenv.isLinux
      [ /* julia */ ]);

    programs.direnv.enable = true;
  };
}
