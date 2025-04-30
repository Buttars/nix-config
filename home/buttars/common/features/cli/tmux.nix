{ config, pkgs, lib, ... }:
{
  programs.tmux =
    let
      tmuxFzfUrl = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-fzf-url";
        version = "2023-11-06";
        src = pkgs.fetchFromGitHub {
          owner = "joshmedeski";
          repo = "tmux-fzf-url";
          rev = "3bc7b34c0321d5dfe4a8d2545be23654ad321fc0";
          sha256 = "sha256-aWqwoJ5L3FB6vZKds7Q4AQ/8Pv2zQnPugL/6BpsBlRo=";
        };
      };
    in
    {
      enable = true;

      # Install TPM and plugins
      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        vim-tmux-navigator
        tmuxFzfUrl
        resurrect
        continuum
      ];

      extraConfig = ''
        ##### ─── Core Options ──────────────────────────────
        set -g default-terminal 'screen-256color'
        set -g base-index 1
        set -g detach-on-destroy off
        set -g escape-time 0
        set -g history-limit 1000000
        set -g mouse on
        set -g renumber-windows on
        set -g set-clipboard on
        set -g status-interval 3
        set -g status-position top
        set -g status-style 'bg=default'

        ##### ─── UI and Status Bar ────────────────
        set -g status-left-length 200
        set -g status-left "#[fg=blue,bold]#S #[fg=white,nobold]#(gitmux -cfg $HOME/.config/tmux/gitmux.conf)"
        set -g status-right '#{?pane_in_mode,#[fg=yellow][COPY],}#{?window_zoomed_flag,#[fg=red][ZOOM],}'
        set -g window-status-current-style fg=brightwhite,bg=magenta
        set -g window-status-current-format ' #I:#W '
        set -g window-status-format '#[fg=gray] #I:#W'

        ##### ─── Pane Appearance ──────────────────────────
        set -g message-command-style bg=default,fg=yellow
        set -g message-style bg=default,fg=yellow
        set -g mode-style bg=default,fg=yellow
        set -g pane-active-border-style 'fg=magenta,bg=default'
        set -g pane-border-style 'fg=brightblack,bg=default'

        ##### ─── Pane and Window Bindings ────────────
        bind '%' split-window -c '#{pane_current_path}' -h
        bind '"' split-window -c '#{pane_current_path}'
        bind c new-window -c '#{pane_current_path}'
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R
        bind -r H resize-pane -L 10
        bind -r J resize-pane -D 10
        bind -r K resize-pane -U 10
        bind -r L resize-pane -R 10

        ##### ─── Custom Tools and Plugins ─────────────────
        bind g new-window -n '' lazygit
        bind G new-window -n '' gh dash
        bind-key u new-window -n '🛠️ devenv' -c '#{pane_current_path}' 'nix develop --accept-flake-config --no-pure-eval --command devenv up'
        bind-key o source-file ~/.config/tmux/open_devenv_windows.tmux
        bind-key O if-shell 'tmux list-windows | grep -q "📜 nvim"' 'kill-window -t "📜 nvim"' \;\
                     if-shell 'tmux list-windows | grep -q "🛠️ devenv"' 'kill-window -t "🛠️ devenv"' \;\
                     if-shell 'tmux list-windows | grep -q "🛢️ lazysql"' 'kill-window -t "🛢️ lazysql"' \;\
                     if-shell 'tmux list-windows | grep -q "🌐 atac"' 'kill-window -t "🌐 atac"'

        ##### ─── Copy Mode ────────────────────────────────
        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
        bind-key e send-keys "tmux capture-pane -p -S - | nvim -c 'set buftype=nofile' +" Enter
        bind x kill-pane

        ##### ─── Sesh/FZF Session Picker ─
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

        ##### ─── Reload Tmux Config ───────────────────────
        bind r source-file $HOME/.config/tmux/tmux.conf \; display "Reloaded!"

        ##### ─── Prefix and Navigation ─────────────────────
        unbind C-b
        set -g prefix C-a
        bind C-a send-prefix

        ##### ─── TPM Bootstrapping ─────────────────────────
        set -g @continuum-restore 'on'
        set -g @plugin 'tmux-plugins/tpm'
        if-shell '[ ! -d ~/.tmux/plugins/tpm ]' \
          'run-shell "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"'
        run '~/.tmux/plugins/tpm/tpm'
      '';
    };
}
