---
name: git-workflow
description: Commit discipline, branch naming, merge strategy, worktree conventions, and the jj/git mechanics that differ.
---

# Version Control

## Identify the tool first

A `.jj` directory means Jujutsu — use `jj`, not `git`. In a colocated repo git
sits in permanently detached HEAD; that is normal, not a problem to fix.

## Commits

- One logical change at a time — if you need "and" to describe it, it should be two commits
- Use imperative mood ("add feature" not "added feature")
- Keep summary line to 80 chars or less
- Omit the commit body unless it references an issue, PR, or external context with no associated ticket
- If the project uses conventional commits, structure as `<type>(<scope>): <description>`
  - Types: feat, fix, docs, style, refactor, test, chore
  - Scope: optional component name

## Branches and merging

- Use flat names — no prefixes (`oauth-flow` not `feat/oauth-flow`)
- Keep names short and descriptive
- Prefer rebase when commits are atomic
- Use PRs for all collaborative or shared branches
- Personal projects may skip PRs and push directly to `master`

## Worktrees

- `git worktree` under git, `jj workspace` under jj
- Each is its own working directory — treat it as its own project (install deps, etc.)
- One per feature; keep `master`, `review`, `hotfix` around
- Be aware of which one is active when running commands
- When one is removed, ask if the branch should also be deleted

## jj mechanics

- There is no staging area — the working copy is a commit. Describe the change
  you already have rather than choosing what to include.
- The cycle is `jj describe -m "..."` then `jj new`. Skipping `jj new` folds the
  next piece of work into the previous commit, whose message then no longer
  describes its contents.
- Separate unrelated work after the fact with `jj split <paths>`.
- Bookmarks do not advance on their own — `jj bookmark set <name> -r @`.

## git mechanics

- Review what's being staged — don't blindly `git add .`
- Stage related changes together, unrelated changes separately

## When I ask you to commit

1. Run `jj st` or `git status` to determine what's new, modified, or deleted
2. jj: describe the current change, then `jj new`. git: stage the relevant files, then commit.
3. Show the generated commit message
4. Execute — no confirmation needed
