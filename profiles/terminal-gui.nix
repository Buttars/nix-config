{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alacritty
  ];

  programs.kitty.enable = true;
}
