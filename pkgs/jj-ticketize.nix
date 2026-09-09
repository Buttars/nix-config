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
    # jj-ticketize [options] <TICKET> [revset]
    # Insert TICKET into each commit summary in a revset (revset defaults to '@'):
    #   "type(scope): msg" -> "type(scope): TICKET - msg"
    # Prepends "TICKET - " when there is no conventional-commit prefix, skips
    # commits that already contain the ticket or have no description, preserves
    # the body, and iterates by stable change_id (safe across rewrites).

    pattern="''${JJ_TICKETIZE_PATTERN:-^[A-Z][A-Z0-9]+-[0-9]+$}"

    usage() {
      printf '%s\n' \
        "usage: jj ticketize [options] <TICKET> [revset]   (revset defaults to '@')" \
        "" \
        "Insert TICKET into each commit summary in a revset:" \
        "  type(scope): msg  ->  type(scope): TICKET - msg" \
        "Prepends 'TICKET - ' when there is no conventional prefix. Skips commits" \
        "already containing the ticket or with an empty description. Body preserved." \
        "" \
        "Options:" \
        "  -n, --dry-run   Show what would change; make no edits." \
        "  -y, --yes       Proceed without confirmation when >1 commit is affected." \
        "      --force     Include immutable/pushed commits (default: skip them)." \
        "  -h, --help      Show this help and exit." \
        "      --          End option parsing." \
        "" \
        "Ticket must match: $pattern  (override with JJ_TICKETIZE_PATTERN)"
    }

    dry_run=0
    assume_yes=0
    force=0
    end_opts=0
    positional=()

    while [ $# -gt 0 ]; do
      if [ "$end_opts" -eq 1 ]; then
        positional+=("$1")
        shift
        continue
      fi
      case "$1" in
        -h | --help)
          usage
          exit 0
          ;;
        -n | --dry-run)
          dry_run=1
          shift
          ;;
        -y | --yes)
          assume_yes=1
          shift
          ;;
        --force)
          force=1
          shift
          ;;
        --)
          end_opts=1
          shift
          ;;
        -*)
          printf 'error: unknown option: %s\n\n' "$1" >&2
          usage >&2
          exit 2
          ;;
        *)
          positional+=("$1")
          shift
          ;;
      esac
    done

    tk="''${positional[0]:-}"
    if [ "''${#positional[@]}" -ge 2 ]; then
      rs="''${positional[1]}"
      rs_given=1
    else
      rs="@"
      rs_given=0
    fi

    if [ -z "$tk" ]; then
      printf 'error: missing <TICKET>\n\n' >&2
      usage >&2
      exit 2
    fi

    if ! printf '%s' "$tk" | grep -qE "$pattern"; then
      printf 'error: ticket %s does not match %s\n' "$tk" "$pattern" >&2
      printf '       (override with JJ_TICKETIZE_PATTERN)\n' >&2
      exit 2
    fi

    # Resolve target change_ids and the immutable subset up front.
    mapfile -t targets < <(jj log -r "$rs" --no-graph -T 'change_id.short() ++ "\n"')
    mapfile -t immutable < <(jj log -r "($rs) & immutable()" --no-graph -T 'change_id.short() ++ "\n"')

    is_immutable() {
      local x="$1" i
      [ "''${#immutable[@]}" -gt 0 ] || return 1
      for i in "''${immutable[@]}"; do
        [ "$i" = "$x" ] && return 0
      done
      return 1
    }

    declare -A newdesc
    plan_ids=()
    plan_before=()
    plan_after=()
    skipped_immutable=()

    for c in "''${targets[@]}"; do
      [ -n "$c" ] || continue
      desc=$(jj log -r "$c" --no-graph -T description)
      [ -n "$desc" ] || continue
      # shellcheck disable=SC2016
      new=$(printf '%s\n' "$desc" | awk -v tk="$tk" 'NR==1{if(index($0,tk)==0){if(match($0,/^[a-z]+(\([^)]*\))?!?: /)){$0=substr($0,1,RLENGTH) tk " - " substr($0,RLENGTH+1)}else{$0=tk " - " $0}}}{print}')
      [ "$new" != "$desc" ] || continue # no-op: already ticketed
      if is_immutable "$c" && [ "$force" -eq 0 ]; then
        skipped_immutable+=("$c  ''${desc%%$'\n'*}")
        continue
      fi
      newdesc["$c"]="$new"
      plan_ids+=("$c")
      plan_before+=("''${desc%%$'\n'*}")
      plan_after+=("''${new%%$'\n'*}")
    done

    if [ "$rs_given" -eq 0 ]; then
      printf 'revset defaulted to @ (%s)\n' "''${targets[0]:-none}" >&2
    fi

    if [ "''${#skipped_immutable[@]}" -gt 0 ]; then
      printf 'warning: skipping %d immutable/pushed commit(s); use --force to include:\n' \
        "''${#skipped_immutable[@]}" >&2
      for s in "''${skipped_immutable[@]}"; do
        printf '  %s\n' "$s" >&2
      done
    fi

    if [ "''${#plan_ids[@]}" -eq 0 ]; then
      printf 'nothing to do.\n'
      exit 0
    fi

    printf 'planned changes (%d):\n' "''${#plan_ids[@]}"
    for i in "''${!plan_ids[@]}"; do
      printf '  %s  %s  ->  %s\n' "''${plan_ids[$i]}" "''${plan_before[$i]}" "''${plan_after[$i]}"
    done

    if [ "$dry_run" -eq 1 ]; then
      printf '(dry run) no changes made.\n'
      exit 0
    fi

    if [ "''${#plan_ids[@]}" -gt 1 ] && [ "$assume_yes" -eq 0 ]; then
      if [ -t 0 ]; then
        printf 'rewrite these %d commit(s)? [y/N] ' "''${#plan_ids[@]}"
        read -r reply
        case "$reply" in
          y | Y | yes | Yes) ;;
          *)
            printf 'aborted.\n'
            exit 1
            ;;
        esac
      else
        printf 'error: refusing to rewrite %d commit(s) non-interactively; pass --yes\n' \
          "''${#plan_ids[@]}" >&2
        exit 2
      fi
    fi

    describe_opts=()
    [ "$force" -eq 1 ] && describe_opts+=(--ignore-immutable)
    for c in "''${plan_ids[@]}"; do
      printf '%s\n' "''${newdesc[$c]}" | jj describe "''${describe_opts[@]}" -r "$c" --stdin
    done
    printf 'ticketized %d commit(s) with %s.\n' "''${#plan_ids[@]}" "$tk"
  '';
}
