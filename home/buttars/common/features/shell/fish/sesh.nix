{ ... }:
{
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
}
