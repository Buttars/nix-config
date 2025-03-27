{ ... }: {
  imports = [
    ./common/core
    ../common/features/programming.nix
    ../common/features/terminal-emulator.nix
    ../common/features/taskwarrior.nix
    ./common/browser.nix
  ];
}
