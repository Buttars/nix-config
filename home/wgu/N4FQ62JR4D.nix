{ pkgs, ... }:
{
  imports = [
    ./core
    ../features/programming.nix
    ../features/terminal-emulator.nix
    ../features/taskwarrior.nix
    ../features/aws.nix
  ];

  programs.zsh.enable = true;

  home.packages = with pkgs; [
    google-chrome
    firefox
  ];

  home.sessionVariables = {
    AVANTE_PROVIDER = "copilot";
    AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
  };

}
