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
            vim-tmux-navigator
          ];

          extraConfig = ''
            # Core
            set -g default-terminal 'screen-256color'
            set -g base-index 1
            set -g detach-on-destroy off
            set -g escape-time 0
            set -g history-limit 1000000
            set -g mouse on
            set -g renumber-windows on
            set -g set-clipboard on
            set -gq allow-passthrough on
            set -g visual-activity off

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

            # Pane navigation
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
            bind-key -T copy-mode-vi 'C-h' select-pane -L
            bind-key -T copy-mode-vi 'C-j' select-pane -D
            bind-key -T copy-mode-vi 'C-k' select-pane -U
            bind-key -T copy-mode-vi 'C-l' select-pane -R
            bind-key -T copy-mode-vi 'v' send-keys -X begin-selection

            # Window cycling (repeatable)
            bind -r n next-window
            bind -r p previous-window

            bind x kill-pane
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
