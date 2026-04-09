{ aegis, lib, ... }:
{
  aegis.zsh = {
    includes = [
      aegis.zsh._.vi-mode
      aegis.zsh._.aliases
      aegis.zsh._.plugins
    ];

    homeManager =
      { config, ... }:
      {
        programs.zsh = {
          enable = true;
          autocd = true;
          enableCompletion = true;

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
        { lib, ... }:
        {
          programs.zsh.initContent = lib.mkBefore ''
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
  };
}
