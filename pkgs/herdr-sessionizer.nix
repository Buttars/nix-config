{
  writeShellScriptBin,
  herdr,
  zoxide,
  fzf,
  jq,
  fd,
  bat,
  eza,
  coreutils,
  gnugrep,
}:

# Unified workspace picker for herdr.
#
# Shows existing herdr workspaces (with live agent status) and zoxide
# directories in one fzf list. Selecting an existing workspace focuses it;
# selecting a directory creates a workspace labeled by the directory basename.
# Outside herdr it attaches afterward.
#
# Selections are keyed on an unambiguous hidden field (workspace id or path),
# so duplicate workspace labels are handled correctly. Each fzf line is:
#   <KEY>\t<DISPLAY>
# where KEY is "ws:<workspace_id>" or "dir:<path>". fzf shows only the display
# column (--with-nth 2) and we parse the key on selection.
#
# fzf bindings:
#   enter   open (focus workspace / create from dir)
#   ctrl-x  close the selected workspace
#   ctrl-f  reload with a filesystem search (fd) instead of zoxide frecency
#   ctrl-z  reload back to the zoxide list
writeShellScriptBin "herdr-sessionizer" ''
  set -euo pipefail
  export PATH="${herdr}/bin:${zoxide}/bin:${fzf}/bin:${jq}/bin:${fd}/bin:${bat}/bin:${eza}/bin:${gnugrep}/bin:${coreutils}/bin:$PATH"

  self="$0"

  # Emit workspace rows: "ws:<id>\t<label>  ·  <status> <panes>p"
  if [ "''${1:-}" = "--list-workspaces" ]; then
    herdr workspace list 2>/dev/null \
      | jq -r '.result.workspaces[]
          | "ws:\(.workspace_id)\t\(.label)  ·  \(.agent_status) \(.pane_count)p"'
    exit 0
  fi

  # Emit zoxide dir rows: "dir:<path>\t<path>", excluding dirs whose basename
  # already matches an existing workspace label.
  if [ "''${1:-}" = "--list-zoxide" ]; then
    ws_labels=$(herdr workspace list 2>/dev/null \
      | jq -r '.result.workspaces[].label' || true)
    zoxide query -l | while IFS= read -r dir; do
      base=$(basename "$dir")
      if ! printf '%s\n' "$ws_labels" | grep -qxF "$base"; then
        printf 'dir:%s\t%s\n' "$dir" "$dir"
      fi
    done
    exit 0
  fi

  # Emit filesystem dir rows via fd.
  if [ "''${1:-}" = "--list-fd" ]; then
    fd --type d --max-depth 4 --hidden --exclude .git . \
      "$HOME/Projects" "$HOME" 2>/dev/null \
      | while IFS= read -r dir; do printf 'dir:%s\t%s\n' "$dir" "$dir"; done
    exit 0
  fi

  # Preview: takes the raw "<KEY>\t<DISPLAY>" line.
  if [ "''${1:-}" = "--preview" ]; then
    key=''${2%%$'\t'*}
    case "$key" in
      ws:*)
        id=''${key#ws:}
        herdr workspace list 2>/dev/null \
          | jq -r --arg id "$id" \
            '.result.workspaces[] | select(.workspace_id == $id)
             | "workspace: \(.label)\nstatus:    \(.agent_status)\ntabs:      \(.tab_count)\npanes:     \(.pane_count)\nid:        \(.workspace_id)"'
        ;;
      dir:*)
        dir=''${key#dir:}
        if [ -d "$dir" ]; then
          eza -la --icons --color=always --group-directories-first "$dir" 2>/dev/null || ls -la "$dir"
          for r in README.md README README.txt; do
            if [ -f "$dir/$r" ]; then
              echo; echo "── $r ──"
              bat --style=plain --color=always --line-range=:40 "$dir/$r" 2>/dev/null || cat "$dir/$r"
              break
            fi
          done
        fi
        ;;
    esac
    exit 0
  fi

  # Close: takes the raw line; only acts on workspace rows.
  if [ "''${1:-}" = "--close" ]; then
    key=''${2%%$'\t'*}
    case "$key" in
      ws:*) herdr workspace close "''${key#ws:}" >/dev/null 2>&1 || true ;;
    esac
    exit 0
  fi

  # --- main picker ---
  pick=$(
    {
      "$self" --list-workspaces
      "$self" --list-zoxide
    } | fzf --height 40% --reverse --border-label ' herdr ' --border \
      --prompt '⚡  ' \
      --delimiter '\t' --with-nth 2.. \
      --preview "$self --preview {}" \
      --preview-window 'right,55%,border-left' \
      --header 'enter open · ctrl-x close · ctrl-f find · ctrl-z zoxide' \
      --bind "ctrl-x:execute-silent($self --close {})+reload($self --list-workspaces; $self --list-zoxide)" \
      --bind "ctrl-f:reload($self --list-fd)" \
      --bind "ctrl-z:reload($self --list-workspaces; $self --list-zoxide)"
  ) || exit 0
  [ -n "$pick" ] || exit 0

  key=''${pick%%$'\t'*}
  case "$key" in
    ws:*)
      herdr workspace focus "''${key#ws:}"
      ;;
    dir:*)
      dir=''${key#dir:}
      herdr workspace create --cwd "$dir" --label "$(basename "$dir")" --focus
      ;;
  esac

  # If invoked from outside herdr (e.g. shell startup), attach now so the
  # focused/created workspace is actually shown. Inside herdr this is a no-op.
  if [ -z "''${HERDR_ENV:-}" ]; then
    exec herdr
  fi
''
