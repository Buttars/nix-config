{
  # Home Manager fragment for terminal emulators
  # Included by: home/* (migrate from home/features/terminal-emulator.nix)
}
{
  features.terminal-emulator = {
    homeManager = { pkgs, ... }:
      {
        home.packages = with pkgs; [
          alacritty
          kitty
        ];
      };
  };
}
