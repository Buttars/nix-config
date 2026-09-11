# Git Workflow

## Commits

- One logical change at a time — if you need "and" to describe it, it should be two commits
- Use imperative mood ("add feature" not "added feature")
- Keep summary line to 80 chars or less
- Omit the commit body unless it references an issue, PR, or external context with no associated ticket
- If the project uses conventional commits, structure as `<type>(<scope>): <description>`
  - Types: feat, fix, docs, style, refactor, test, chore
  - Scope: optional component name

## Branches

- Use flat names — no prefixes (`oauth-flow` not `feat/oauth-flow`)
- Keep names short and descriptive

## Staging

- Review what's being staged — don't blindly `git add .`
- Stage related changes together, unrelated changes separately

## Merging

- Prefer rebase when commits are atomic
- Use PRs for all collaborative or shared branches
- Personal projects may skip PRs and push directly to `master`

## Worktrees

- Each worktree is its own working directory — treat it as its own project (install deps, etc.)
- Create a new worktree per feature
- Stable worktrees to keep around: `master`, `review`, `hotfix`
- Be aware of which worktree is active when running git commands
- When a worktree is removed, ask if the branch should also be deleted

## When I ask you to commit

1. Run `git status` to determine what's new, modified, or deleted
2. Stage relevant files
3. Show the generated commit message
4. Execute — no confirmation needed
