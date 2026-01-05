{ pkgs, ... }:
{
  imports = [
    ./core
    ../features/programming.nix
    ../features/terminal-emulator.nix
    ../features/taskwarrior.nix
    ../features/aws.nix
    ../features/programming/npm.nix
  ];

  programs.zsh.enable = true;

  progrmas.npm = {
    enable = true;
    enableXdgSupport = true;
    settings = {

    };
    extraConfig = '''';
  };

  home.packages = with pkgs; [
    gleam
    erlang
    google-chrome
    # firefox
  ];

  home.sessionVariables = {
    AVANTE_PROVIDER = "copilot";
    AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
  };

}
