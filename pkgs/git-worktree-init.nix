{
  writeShellScriptBin,
  git,
  gum,
}:

writeShellScriptBin "git-worktree-init" ''
  set -euo pipefail
  PATH="${git}/bin:${gum}/bin:$PATH"

  if [ $# -lt 1 ]; then
    echo "Usage: git-worktree-init <repo-url> [directory]" >&2
    exit 1
  fi

  repo="$1"
  dir="''${2:-$(basename "$repo" .git)}"

  mkdir -p "$dir"
  git clone --bare "$repo" "$dir/.repo"
  echo "gitdir: .repo" > "$dir/.git"

  cd "$dir"
  git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git fetch

  git for-each-ref --format='%(refname:short)' refs/heads | xargs -n1 -I{} git branch --set-upstream-to=origin/{}

  # Detect default branch
  if git show-ref --verify --quiet refs/remotes/origin/master; then
    default_branch="master"
  else
    default_branch="main"
  fi

  # Prompt for worktrees to create
  choices=$(gum choose --no-limit --selected="$default_branch" \
    "$default_branch" "review" "hotfix")

  for branch in $choices; do
    if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
      git worktree add "$branch" "$branch"
    else
      git worktree add "$branch" -b "$branch"
    fi
  done
''
