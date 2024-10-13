{ config, pkgs, ... }: {
  imports = [ ];

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
}
