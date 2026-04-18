{
  den.aspects.buttars.homeManager =
    { lib, pkgs, ... }:
    {
      programs.fish = {
        enable = true;

        shellAliases = {
          ll = "ls -la";
          dotfiles = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
          discord = "discord -enable-features=UseOzonePlatform -ozone-platform=wayland";
          ka = "killall";
          g = "git";
          sdn = "shutdown -h now";
          e = "$EDITOR";
          v = "$EDITOR";
          f = "fuck";
        };

        interactiveShellInit = ''
          if test -f $HOME/.config/sops-nix/secrets/rendered/neovim-avante.env
            source $HOME/.config/sops-nix/secrets/rendered/neovim-avante.env
          end

          function cp; command cp -iv $argv; end
          function mv; command mv -iv $argv; end
          function rm; command rm -vI $argv; end
          function rsync; command rsync -vrPlu $argv; end

          function define_sudo_wrappers --argument-names commands
            for cmd in $commands
              set -l def "
              function $cmd
                  command sudo -- $cmd \$argv
              end"
              eval $def
            end
          end

          define_sudo_wrappers mount umount shutdown reboot sv su

          fish_vi_key_bindings

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
