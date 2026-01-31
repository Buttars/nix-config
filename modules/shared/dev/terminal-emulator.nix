{
  shared.terminal-emulator.home-manager = { pkgs, ... }:
    {
      home.packages = with pkgs; [ alacritty kitty ];
    };
}
