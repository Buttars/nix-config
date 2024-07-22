{ config, pkgs, ... }: {
  imports = [ ];

  environment.systemPackages = with pkgs; [
    lf
    feh
    nsxiv
    zathura
    bat
    ueberzug
    file
    mpv
  ];
}
