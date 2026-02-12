{
  # Home Manager fragment for terminal emulators
  # Included by: home/* (migrate from home/features/terminal-emulator.nix)

  aegis.terminal-emulator = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          alacritty
          kitty
        ];
      };
  };
}
