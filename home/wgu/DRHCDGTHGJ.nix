{ pkgs, config, ... }:
{
  imports = [
    ./core
    ../../home-manager
    {
      dotfiles.mutable = true;
      dotfiles.path = "${config.home.homeDirectory}/nix-config/master/dotfiles";
    }
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
    colima
    git-worktree-switcher
    amazon-q-cli
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

  programs.ssh = {
    enable = true;

    matchBlocks = {
      "github.com-buttars" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
        identitiesOnly = true;
      };

      # Default GitHub = work
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };

    extraConfig = ''
      Host *
        AddKeysToAgent yes
        UseKeychain yes
        ServerAliveInterval 30
        ServerAliveCountMax 3
    '';
  };

  home.sessionVariables = {
    AVANTE_PROVIDER = "openai";
    AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
  };

}
