{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wvkbd
    maliit-keyboard
    maliit-framework
  ];
}
