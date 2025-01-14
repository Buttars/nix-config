{ pkgs, ... }: {
  imports = [
    ./bat.nix
    ./bash.nix
    ./direnv.nix
    ./fish.nix
    ./fzf.nix
    ./starship.nix
  ];
  home.packages = with pkgs; [
    keepassxc
  ];
}
