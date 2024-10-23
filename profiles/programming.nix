{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.programming;
in

{
  options.host.profiles.programming = {
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
      pnpm
      python3
      ripgrep
    ] ++
    (pkgs.lib.optionals
      pkgs.stdenv.isLinux
      [ /* julia */ ]);

    programs.direnv.enable = true;
  };
}
