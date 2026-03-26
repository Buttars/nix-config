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

          function sesh-sessions
            set -l session (sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
            if test -n "$session"
              sesh connect $session
            end
          end
          bind \es sesh-sessions

          function sesh-start
            set -l session (sesh connect (sesh list -i | fzf-tmux -p 55%,60% --layout=reverse --ansi \
              --no-sort --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t -i)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c -i)' \
              --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z -i)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t (echo {} | cut -c3-))+change-prompt(⚡  )+reload(sesh list -i)'
            ))
            if test -n "$session"
              sesh connect $session
            end
          end

          if not set -q TMUX
            if not status --is-login
              sesh-start
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
