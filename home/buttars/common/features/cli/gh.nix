{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gh
  ];
}
