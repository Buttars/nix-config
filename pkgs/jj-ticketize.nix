{
  writeShellApplication,
  jujutsu,
  gawk,
}:
writeShellApplication {
  name = "jj-ticketize";
  runtimeInputs = [
    jujutsu
    gawk
  ];
  text = ''
    # jj-ticketize <TICKET> [revset]
    # Insert TICKET into each commit summary in a revset (defaults to '@'):
    #   "type(scope): msg" -> "type(scope): TICKET - msg"
    # Prepends when there is no conventional-commit prefix, skips commits that
    # already contain the ticket or have no description, and preserves the body.
    usage() {
      echo "usage: jj ticketize <TICKET> [revset]   (revset defaults to '@')" >&2
      exit 2
    }
    tk="''${1:-}"
    rs="''${2:-@}"
    [ -n "$tk" ] || usage

    # change_ids are stable across rewrites, so iterating them is safe.
    jj log -r "$rs" --no-graph -T 'change_id.short() ++ "\n"' | while IFS= read -r c; do
      [ -n "$c" ] || continue
      desc=$(jj log -r "$c" --no-graph -T description)
      [ -n "$desc" ] || continue
      # shellcheck disable=SC2016
      printf '%s\n' "$desc" \
        | awk -v tk="$tk" 'NR==1{if(index($0,tk)==0){if(match($0,/^[a-z]+(\([^)]*\))?!?: /)){$0=substr($0,1,RLENGTH) tk " - " substr($0,RLENGTH+1)}else{$0=tk " - " $0}}}{print}' \
        | jj describe -r "$c" --stdin
    done
  '';
}
