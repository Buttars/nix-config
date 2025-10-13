{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      taskwarrior3
      taskwarrior-tui
    ]
    ++ (lib.optionals pkgs.stdenv.isLinux [
      taskopen
    ]);
}
