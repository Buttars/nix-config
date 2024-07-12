{ config, pkgs, ... }: {
  imports = [ ];

  environment.systemPackages = with pkgs; [
    wvkbd
    maliit-keyboard
    maliit-framework
  ];

}
