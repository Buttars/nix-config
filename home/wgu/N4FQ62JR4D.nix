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
    gleam
    erlang
    google-chrome
    # firefox
    (pkgs.python3.withPackages (
      ps: with ps; [
        jupyterlab
        ipykernel
        numpy
        pandas
      ]
    ))
  ];

  home.sessionVariables = {
    AVANTE_PROVIDER = "copilot";
    AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
  };

}
