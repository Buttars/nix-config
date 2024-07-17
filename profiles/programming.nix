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
    julia
  ];

}
