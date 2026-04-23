{
  den.aspects.buttars.homeManager =
    { ... }:
    {
      programs.fish = {
        shellAliases = {
          dotfiles = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
          discord = "discord -enable-features=UseOzonePlatform -ozone-platform=wayland";
          f = "fuck";
        };

        interactiveShellInit = ''
          if test -f $HOME/.config/sops-nix/secrets/rendered/neovim-avante.env
            source $HOME/.config/sops-nix/secrets/rendered/neovim-avante.env
          end

          if test (tty) = "/dev/tty1"
            if type -q Hyprland
              if not pgrep -x Hyprland > /dev/null
                exec start-hyprland
              end
            end
          end
        '';
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
        BROWSER = "brave";
        INPUTRC = "$XDG_CONFIG_HOME/shell/inputrc";
      };
    };
}
