{ pkgs, ... }:
{
  imports = [
    ./common/core
    ../common/features/programming.nix
    ../common/features/terminal-emulator.nix
    ../common/features/taskwarrior.nix
    ../common/features/aws.nix
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
