# Canonical agent definitions. Tool-neutral: `tools` and `mcp` are abstract
# capability names, `tier` is a model class, `rules`/`standards`/`skills` are
# basenames. _mappings.nix translates all of them into one harness's concrete
# names. Attr key is the agent file/name (override with `name`).
#
# `default.rules` and `default.standards` are the universal baseline — every
# agent receives both, so other agents list only what they add on top. skills
# are scoped per agent (not "all") so each spawned session loads less context.
#
# Standards are protocol rather than preference, which is why they are not
# scoped: an agent that opts out of the handoff contract breaks the agents it
# hands off to. `session` plus the agentSpawn hook let work share findings
# through `.kiro/notes.md` instead of rediscovering them.
#
# `tools` and `mcp` are deliberately narrow per agent. Tool and MCP server
# definitions are the bulk of an agent's starting context, so a capability is
# granted where the role needs it rather than everywhere. An omitted `mcp` means
# no servers, not all of them.
#
# `approvedCommands` has no effect on headless runs — kiro-cli denies shell
# non-interactively regardless. See ~/.config/ai-knowledge, kiro-cli-internals.
{
  default = {
    prompt = "routing";
    standards = [
      "core"
      "handoff"
      "session"
    ];
    rules = [
      "response-style"
      "verification"
      "comments"
      "editing"
    ];
    context = [ "ai-module" ];
    skills = [
      "engineering/ask-matt"
      "productivity/grill-me"
    ];
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
      "web"
      "spawn"
      "aws"
    ];
    mcp = [
      "forge"
      "docs"
      "tickets"
      "infra"
      "flags"
      "terminal"
      "files"
    ];
    trustedAgents = [
      "reviewer"
      "version-control"
      "coder"
      "architect"
      "docs"
      "fixer"
      "message-writer"
      "writing"
      "technical-writer"
    ];
    approveReadonlyShell = true;
    approvedCommands = [
      "jj log.*"
      "jj diff.*"
      "jj show.*"
      "jj status.*"
      "jj config.*"
      "jj bookmark list.*"
      "git log.*"
      "git diff.*"
      "git status.*"
      "git branch.*"
      "git remote.*"
      "git stash list.*"
    ];
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
  };

  # User-invoked mode (via `/agent`), not a delegation target — `fixer` is the
  # delegated fix lane and shares this prompt.
  focused-mode = {
    name = "focused-fix";
    description = "Scoped to a single fix or small feature — minimal changes, no cleanup, no extras";
    rules = [ ];
    skills = [ ];
    prompt = "focused-mode";
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
    ];
    mcp = [
      "docs"
      "forge"
      "terminal"
    ];
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Focused mode active. What's the single thing we're fixing?";
  };

  architect = {
    description = "System design, tech decisions, ADRs, and high-level planning";
    rules = [
      "tech-stack"
      "dev-environment"
    ];
    skills = [
      "engineering/codebase-design"
      "engineering/domain-modeling"
      "engineering/to-spec"
      "engineering/wayfinder"
      "engineering/research"
    ];
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
      "web"
      "spawn"
      "aws"
    ];
    mcp = [
      "docs"
      "tickets"
      "infra"
      "flags"
      "forge"
    ];
    # core.md puts critique in parallel under one decision-maker, which only
    # works if the agent holding the decision can spawn the critics.
    trustedAgents = [
      "reviewer"
      "docs"
    ];
    approveReadonlyShell = true;
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Architect ready. What are we designing?";
  };

  coder = {
    description = "Implements features and fixes — correct, idiomatic, and scoped to exactly what's asked";
    rules = [
      "tech-stack"
      "dev-environment"
      "refactoring"
      "debugging"
    ];
    skills = [
      "engineering/tdd"
      "engineering/implement"
      "engineering/codebase-design"
      "engineering/diagnosing-bugs"
    ];
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
      "aws"
    ];
    mcp = [
      "docs"
      "forge"
      "infra"
      "flags"
      "terminal"
    ];
    approveReadonlyShell = true;
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Coder ready. What are we building?";
  };

  docs = {
    description = "Writes and improves documentation — READMEs, docstrings, changelogs, specs";
    prompt = "docs";
    rules = [ ];
    context = [ "ai-module" ];
    skills = [ "productivity/writing-for-agents" ];
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
      "web"
    ];
    mcp = [
      "docs"
      "forge"
    ];
    approveReadonlyShell = true;
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Docs agent ready. What needs writing or improving?";
  };

  version-control = {
    description = "Manages version control — commits, branches, history, and PRs";
    rules = [
      "version-control"
    ];
    skills = [
      "jujutsu"
      "engineering/resolving-merge-conflicts"
      "misc/git-guardrails-claude-code"
    ];
    tools = [
      "read"
      "search"
      "edit"
      "shell"
    ];
    mcp = [ "forge" ];
    approveReadonlyShell = true;
    approvedCommands = [
      "jj log.*"
      "jj diff.*"
      "jj show.*"
      "jj status.*"
      "jj config.*"
      "jj bookmark list.*"
      "jj bookmark create.*"
      "jj bookmark set.*"
      "jj new.*"
      "jj describe.*"
      "jj squash.*"
      "jj rebase.*"
      "jj git push.*"
      "jj git fetch.*"
      "jj git remote.*"
      "git log.*"
      "git diff.*"
      "git status.*"
      "git branch.*"
      "git remote.*"
      "git stash.*"
      "git add.*"
      "git commit.*"
      "git push.*"
      "git fetch.*"
      "git pull.*"
      "gh pr create.*"
      "gh pr list.*"
      "gh pr view.*"
    ];
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Version control ready. What needs committing, branching, or pushing?";
  };

  reviewer = {
    description = "Reviews code and PRs — flags issues, suggests improvements, enforces standards";
    rules = [
      "refactoring"
      "debugging"
      "tech-stack"
    ];
    skills = [
      "engineering/code-review"
      "engineering/improve-codebase-architecture"
      "engineering/codebase-design"
    ];
    # No edit capability: core.md requires that review and authorship stay in
    # separate agents, and withholding the tool is what enforces it.
    tools = [
      "read"
      "search"
      "code"
      "shell"
    ];
    mcp = [
      "forge"
      "docs"
    ];
    approveReadonlyShell = true;
    approvedCommands = [
      "jj log.*"
      "jj diff.*"
      "jj show.*"
      "jj status.*"
      "git log.*"
      "git diff.*"
      "git status.*"
      "git show.*"
    ];
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Reviewer ready. Point me at the code or PR.";
  };

  message-writer = {
    description = "Writes, revises, and refines messages to a person — email, Slack, text, casual";
    prompt = "message-writing";
    rules = [ ];
    skills = [ ];
    tools = [ "read" ];
    mcp = [ ];
    welcomeMessage = "Message mode. Paste a draft to revise or refine, or tell me what to write.";
  };

  writing = {
    description = "Writes and revises durable non-technical documents — essays, journals, letters, personal plans, notes";
    prompt = "writing";
    rules = [ ];
    skills = [ ];
    tools = [
      "read"
      "edit"
    ];
    mcp = [ ];
    welcomeMessage = "Writing mode. Paste a document to revise or refine, or tell me what to write.";
  };

  technical-writer = {
    description = "Writes concise, accurate technical communication — ticket/PR comments, status updates, and summaries of work";
    prompt = "technical-writing";
    rules = [ ];
    skills = [ ];
    tools = [
      "read"
      "search"
      "shell"
    ];
    mcp = [
      "tickets"
      "forge"
    ];
    approveReadonlyShell = true;
    approvedCommands = [
      "jj log.*"
      "jj diff.*"
      "jj show.*"
      "jj status.*"
      "git log.*"
      "git diff.*"
      "git status.*"
      "git show.*"
    ];
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Technical writing mode. Point me at the work (or paste the details) and say the format — ticket comment, PR, status update, etc.";
  };

  fixer = {
    description = "Delegated fixes — the smallest correct change to resolve a reported issue, nothing beyond it";
    prompt = "focused-mode";
    rules = [
      "debugging"
      "refactoring"
    ];
    skills = [ "engineering/diagnosing-bugs" ];
    tools = [
      "read"
      "search"
      "code"
      "edit"
      "shell"
      "aws"
    ];
    mcp = [
      "docs"
      "forge"
      "infra"
      "terminal"
    ];
    approveReadonlyShell = true;
    hooks.agentSpawn = [ { command = "cat .kiro/notes.md 2>/dev/null || true"; } ];
    welcomeMessage = "Fixer ready. What's the reported issue?";
  };

}
