{ config, pkgs, ... }: {
  imports = [];

  environment.systemPackages = with pkgs; [
    nodejs
    cargo
    gcc
  ];

}
