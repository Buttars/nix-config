{
  den,
  aegix,
  lib,
  ...
}:
{
  aegix.tmux = {
    nixos.programs.tmux.enable = true;
    darwin.programs.tmux.enable = true;

    homeManager =
      { config, pkgs, ... }:
      let
        bw-picker = pkgs.writeShellScript "bw-picker" ''
          export PATH="${pkgs.bitwarden-cli}/bin:${pkgs.jq}/bin:${pkgs.fzf}/bin:${pkgs.tmux}/bin:${pkgs.gum}/bin:$PATH"
          [ -f "$HOME/.bw_session" ] && BW_SESSION="$(cat "$HOME/.bw_session")"
          if [ -z "$(echo "$BW_SESSION" | tr -d '[:space:]')" ]; then
            BW_SESSION=$(gum input --password --prompt "🔒 Master password: " | bw unlock --raw --passwordfile /dev/stdin)
            if [ -z "$BW_SESSION" ]; then
              BW_SESSION=$(bw login --raw)
            fi
            [ -z "$BW_SESSION" ] && exit 1
            echo "$BW_SESSION" > "$HOME/.bw_session" && chmod 600 "$HOME/.bw_session"
          fi
          ITEMS=$(bw list items --session "$BW_SESSION" 2>&1)
          if echo "$ITEMS" | grep -qiE "locked|not logged in|unauthenticated"; then
            BW_SESSION=$(gum input --password --prompt "🔒 Master password: " | bw unlock --raw --passwordfile /dev/stdin)
            [ -z "$BW_SESSION" ] && exit 1
            echo "$BW_SESSION" > "$HOME/.bw_session" && chmod 600 "$HOME/.bw_session"
            ITEMS=$(bw list items --session "$BW_SESSION")
          fi
          ITEM=$(echo "$ITEMS" | jq -r '.[] | select(.login) | "\(.name) (\(.login.username))"' | gum filter --prompt="🔑 " --placeholder="Search passwords...")
          [ -z "$ITEM" ] && exit 0
          NAME=$(echo "$ITEM" | sed 's/ (.*//')
          bw get password "$NAME" --session "$BW_SESSION" | tmux load-buffer - && tmux paste-buffer -d
        '';
      in
      {
        options.tmux.hasStatusRightProvider = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        config.programs.tmux = {
          enable = true;

          plugins = with pkgs.tmuxPlugins; [
            sensible
            yank
          ];

          extraConfig = ''
            # Core
            set -g default-terminal 'tmux-256color'
            set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
            set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
            set -g base-index 1
            set -g detach-on-destroy off
            set -g escape-time 0
            set -g history-limit 1000000
            set -g mouse on
            set -g focus-events on
            set -g renumber-windows on
            set -g set-clipboard on
            set -gq allow-passthrough on
            set -g visual-activity off
            set -g repeat-time 200

            # Status bar
            set -g status-interval 3
            set -g status-position top
            set -g status-style 'bg=default'
            set -g status-left-length 200
            set -g status-left "#[fg=blue,bold]#S"
            ${lib.optionalString (!config.tmux.hasStatusRightProvider)
              "set -g status-right '#{?pane_in_mode,#[fg=yellow][COPY],}#{?window_zoomed_flag,#[fg=red][ZOOM],}'"
            }
            set -g window-status-current-style fg=brightwhite,bg=magenta
            set -g window-status-current-format ' #I:#W '
            set -g window-status-format '#[fg=gray] #I:#W'

            # Pane appearance
            set -g message-command-style bg=default,fg=yellow
            set -g message-style bg=default,fg=yellow
            set -g mode-style bg=default,fg=yellow
            set -g pane-active-border-style 'fg=magenta,bg=default'
            set -g pane-border-style 'fg=brightblack,bg=default'

            # Prefix
            unbind C-b
            set -g prefix C-a
            bind C-a send-prefix

            # Pane navigation (vim-tmux-navigator via pgrep to handle kiro-cli-term wrapper)
            bind-key -T root C-h if-shell "pgrep -P $(pgrep -P #{pane_pid}) | xargs -I{} ps -o comm= -p {} 2>/dev/null | grep -iqE '(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?|neovim'" "send-keys C-h" "select-pane -L"
            bind-key -T root C-j if-shell "pgrep -P $(pgrep -P #{pane_pid}) | xargs -I{} ps -o comm= -p {} 2>/dev/null | grep -iqE '(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?|neovim'" "send-keys C-j" "select-pane -D"
            bind-key -T root C-k if-shell "pgrep -P $(pgrep -P #{pane_pid}) | xargs -I{} ps -o comm= -p {} 2>/dev/null | grep -iqE '(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?|neovim'" "send-keys C-k" "select-pane -U"
            bind-key -T root C-l if-shell "pgrep -P $(pgrep -P #{pane_pid}) | xargs -I{} ps -o comm= -p {} 2>/dev/null | grep -iqE '(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?|neovim'" "send-keys C-l" "select-pane -R"

            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R
            bind -r H resize-pane -L 10
            bind -r J resize-pane -D 10
            bind -r K resize-pane -U 10
            bind -r L resize-pane -R 10

            # Window/pane creation inherits path
            bind '%' split-window -c '#{pane_current_path}' -h
            bind '"' split-window -c '#{pane_current_path}'
            bind c new-window -c '#{pane_current_path}'

            # Copy mode vi bindings
            set -g mode-keys vi
            bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
            bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe-and-cancel "pbcopy"

            # Scrollback search
            bind / copy-mode \; send-keys /

            # Window cycling (repeatable)
            bind -r n next-window
            bind -r p previous-window

            bind x kill-pane
            bind P display-popup -E -w 60% -h 60% '${bw-picker}'
            bind r source-file ~/.config/tmux/tmux.conf \; display-message "  config reloaded"
          '';
        };
      };

    _.full = {
      includes = [
        aegix.tmux
        aegix.tmux._.extras
        aegix.tmux._.sesh
        aegix.tmux._.gitmux
      ];
    };

    _.extras = {
      homeManager =
        { pkgs, ... }:
        {
          programs.tmux = {
            plugins = with pkgs.tmuxPlugins; [
              fzf-tmux-url
              resurrect
              continuum
            ];

            extraConfig = ''
              set -g @continuum-restore 'on'

              bind g new-window -n ''' lazygit
              bind G new-window -n ''' gh dash
              bind-key u new-window -n '🛠️ devenv' -c '#{pane_current_path}' 'nix develop --accept-flake-config --no-pure-eval --command devenv up'
              bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter
            '';
          };
        };
    };

    _.sesh = {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.sesh ];

          programs.tmux.extraConfig = ''
            bind-key "f" run-shell "sesh connect \"$(
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
            )\""
          '';

          programs.fish.interactiveShellInit = ''
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
    };

    _.gitmux = {
      homeManager =
        { pkgs, ... }:
        {
          tmux.hasStatusRightProvider = true;

          home.packages = [ pkgs.gitmux ];

          programs.tmux.extraConfig = ''
            set -g status-right "#[fg=white,nobold]#(gitmux -cfg $XDG_CONFIG_HOME/tmux/gitmux.conf) #{?pane_in_mode,#[fg=yellow][COPY],}#{?window_zoomed_flag,#[fg=red][ZOOM],}"
          '';

          xdg.configFile."tmux/gitmux.conf".text = ''
            tmux:
              symbols:
                branch: '󰘬 '
                hashprefix: ':'
                ahead: ' '
                behind: ' '
                staged: ' '
                conflict: '󰕚'
                untracked: '??'
                modified: ' '
                stashed: ' '
                clean: 'c'
                insertions: ' '
                deletions: ' '
              styles:
                state: '#[fg=red,nobold]'
                branch: '#[fg=white,nobold]'
                staged: '#[fg=green,nobold]'
                conflict: '#[fg=red,nobold]'
                modified: '#[fg=yellow,nobold]'
                untracked: '#[fg=gray,nobold]'
                stashed: '#[fg=gray,nobold]'
                clean: '#[fg=green,nobold]'
                divergence: '#[fg=cyan,nobold]'
              layout: [branch, divergence, flags, stats, ' ']
              options:
                branch_max_len: 0
                hide_clean: true
          '';
        };
    };
  };
}
