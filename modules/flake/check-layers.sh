# Comments reference aspects for documentation; those are not dependencies.
body=$(grep -v '^[[:space:]]*#' "$f" 2>/dev/null)
refs=$(printf '%s\n' "$body" | grep -oE '<aegix/[a-zA-Z0-9_-]+' | sed 's|<aegix/||')#!/usr/bin/env bash
# Enforces the module structure documented in docs/architecture/module-structure.md:
#   1. one aspect, one file
#   2. layer dependency direction
set -uo pipefail

root="${1:-.}"
modules="$root/modules"
status=0

layers="profile capability app platform"
siblings="hardware lib"

declare -A owner
for l in $layers $siblings; do
  for f in "$modules/$l"/*.nix; do
    [ -e "$f" ] || continue
    owner["$(basename "$f" .nix)"]=$l
  done
  for d in "$modules/$l"/*/; do
    [ -e "$d" ] || continue
    owner["$(basename "$d")"]=$l
  done
done

allowed() {
  case "$1:$2" in
  *:hardware | *:lib) return 0 ;;
  profile:capability | profile:profile) return 0 ;;
  capability:app | capability:platform | capability:capability) return 0 ;;
  app:platform) return 0 ;;
  *) return 1 ;;
  esac
}

# 1. one aspect, one file
dupes=$(grep -rhoE '^[[:space:]]{0,4}aegix\.[a-zA-Z0-9_-]+' "$modules" 2>/dev/null |
  tr -d ' ' | sed 's/aegix\.//' | sort | uniq -c | awk '$1 > 1 {print $2}')
for d in $dupes; do
  # a directory-shaped aspect legitimately spans files under its own directory
  files=$(grep -rlE "^[[:space:]]{0,4}aegix\.$d\b" "$modules" 2>/dev/null)
  dirs=$(echo "$files" | xargs -r -n1 dirname | sort -u | wc -l)
  if [ "$dirs" -gt 1 ]; then
    echo "FAIL one-aspect-one-file: aegix.$d is declared in more than one place:"
    echo "$files" | sed "s|^|    |"
    status=1
  fi
done

# 2. layer direction
for l in $layers; do
  while IFS= read -r f; do
    [ -e "$f" ] || continue
    # Comments reference aspects for documentation, not as dependencies.
    body=$(grep -v '^[[:space:]]*#' "$f" 2>/dev/null)
    refs=$(printf '%s\n' "$body" | grep -oE '<aegix/[a-zA-Z0-9_-]+' | sed 's|<aegix/||')
    refs="$refs $(printf '%s\n' "$body" | grep -oE '(^|[^.a-zA-Z0-9_-])aegix\.[a-zA-Z0-9_-]+' |
      sed 's/.*aegix\.//')"
    for r in $refs; do
      to="${owner[$r]:-}"
      [ -n "$to" ] || continue
      # a file declaring aspect X names X itself; that is not a dependency
      [ "$r" = "$(basename "$f" .nix)" ] && continue
      [ "$r" = "$(basename "$(dirname "$f")")" ] && continue
      if ! allowed "$l" "$to"; then
        echo "FAIL layer-direction: ${f#"$root"/} ($l) -> $r ($to)"
        status=1
      fi
    done
  done < <(find "$modules/$l" -name '*.nix')
done

[ $status -eq 0 ] && echo "module layering OK"
exit $status
