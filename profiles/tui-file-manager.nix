{ pkgs, system, superfile, ... }: {
  imports = [ ];

  environment.systemPackages = with pkgs; [
    lf
    superfile.${system}
    feh
    nsxiv
    zathura
    bat
    ueberzug
    file
    mpv
  ];
}
