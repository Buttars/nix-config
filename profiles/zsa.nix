{ config, pkgs, ... }: {
  imports = [ ];

  hardware.keyboard.zsa.enable = true;

  environment.systemPackages = with pkgs; [
    wally-cli
  ];

}
