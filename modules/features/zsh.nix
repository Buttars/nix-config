{ aegix, lib, ... }:
{
  aegix.zsh = {
    includes = [
      aegix.zsh._.vi-mode
      aegix.zsh._.aliases
      aegix.zsh._.plugins
    ];

    homeManager =
      { config, ... }:
      {
        programs.zsh = {
          enable = true;
          autocd = true;
          enableCompletion = true;

          initContent = ''
            stty stop undef
            setopt interactive_comments
          '';

          history = {
            size = 10000000;
            save = 10000000;
            path = "${config.xdg.cacheHome}/zsh/history";
          };

          completionInit = ''
            autoload -U compinit
            zstyle ':completion:*' menu select
            zmodload zsh/complist
            compinit
            _comp_options+=(globdots)
          '';
        };
      };

    _.vi-mode = {
      homeManager =
        { ... }:
        {
          programs.zsh.initContent = ''
            bindkey -v
            export KEYTIMEOUT=100

            bindkey -M menuselect 'h' vi-backward-char
            bindkey -M menuselect 'k' vi-up-line-or-history
            bindkey -M menuselect 'l' vi-forward-char
            bindkey -M menuselect 'j' vi-down-line-or-history
            bindkey -v '^?' backward-delete-char
            bindkey "^R" history-incremental-search-backward

            function zle-keymap-select () {
              case $KEYMAP in
                vicmd) echo -ne '\e[1 q';;
                viins|main) echo -ne '\e[5 q';;
              esac
            }
            zle -N zle-keymap-select
            zle-line-init() {
              zle -K viins
              echo -ne "\e[5 q"
            }
            zle -N zle-line-init
            echo -ne '\e[5 q'
            preexec() { echo -ne '\e[5 q' ;}

            autoload edit-command-line; zle -N edit-command-line
            bindkey '^e' edit-command-line
            bindkey -M vicmd '^e' edit-command-line
          '';
        };
    };

    _.aliases = {
      homeManager =
        { pkgs, ... }:
        {
          programs.zsh.shellAliases = {
            cp = "cp -iv";
            mv = "mv -iv";
            rm = "rm -vI";
            mkd = "mkdir -pv";
            ll = "ls -la";
            grep = "grep --color=auto";
            diff = "diff --color=auto";
            ka = "killall";
            g = "git";
            e = "$EDITOR";
            v = "$EDITOR";
          }
          // lib.optionalAttrs pkgs.stdenv.isDarwin {
            ls = "ls -hG";
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            ls = "ls -hN --color=auto --group-directories-first";
            ip = "ip -color=auto";
            sdn = "shutdown -h now";
          };
        };
    };

    _.plugins = {
      homeManager =
        { ... }:
        {
          programs.zsh = {
            syntaxHighlighting.enable = true;
            historySubstringSearch.enable = true;
          };
        };
    };

    _.prompt = {
      homeManager =
        { ... }:
        {
          programs.zsh.initContent = ''
            autoload -U colors && colors
            PS1="%B%{$fg[blue]%}[%{$fg[green]%}%~%{$fg[blue]%}]%{$fg[red]%}$%b "
          '';
        };
    };

    _.sesh = {
      homeManager =
        { ... }:
        {
          programs.zsh.initContent = ''
            function sesh-sessions() {
              local session
              session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
              if [[ -n "$session" ]]; then
                sesh connect "$session"
              fi
            }
            bindkey -s '\es' '^usesh-sessions\n'

            function sesh-start() {
              sesh connect "$(
                sesh list -i | fzf-tmux -p 55%,60% --layout=reverse --ansi \
                  --no-sort --border-label ' sesh ' --prompt '⚡  ' \
                  --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
                  --bind 'tab:down,btab:up' \
                  --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
                  --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t -i)' \
                  --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c -i)' \
                  --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z -i)' \
                  --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
                  --bind 'ctrl-d:execute(tmux kill-session -t $(echo {} | cut -c3-))+change-prompt(⚡  )+reload(sesh list -i)'
              )"
            }

            if [[ -z "$TMUX" ]]; then
              if [[ "$(uname)" == "Darwin" ]] || [[ ! -o login ]]; then
                sesh-start
              fi
            fi
          '';
        };
    };

    _.fzf-nav = {
      homeManager =
        { ... }:
        {
          programs.zsh.initContent = ''
            bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
          '';
        };
    };
  };
}
