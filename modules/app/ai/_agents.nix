# Canonical agent definitions. Tool-neutral: `rules` are steering basenames and
# `skills` is "all" or a list of skill names; adapters map these to each tool's
# resource URIs. Attr key is the agent file/name (override with `name`).
#
# response-style is kept only on user-facing agents (dispatcher, coder); agents
# spawned as subagents report to a parent, so it is omitted for them. skills are
# scoped per agent (not "all") so each spawned session loads less context.
{
  default = {
    prompt = "routing";
    rules = [ "response-style" ];
    context = [ "ai-module" ];
    mcpServers = "all";
    skills = [
      "engineering/ask-matt"
      "productivity/grill-me"
    ];
    trustedAgents = [
      "reviewer"
      "git"
      "coder"
      "architect"
      "docs"
      "focused-fix"
      "fixer"
      "writer"
      "technical-writer"
    ];
    bash = {
      autoAllowReadonly = true;
      allowedCommands = [
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
    };
  };

  focused-mode = {
    name = "focused-fix";
    description = "Scoped to a single fix or small feature — minimal changes, no cleanup, no extras";
    rules = [ ];
    skills = [ ];
    prompt = "focused-mode";
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
    bash.autoAllowReadonly = true;
    welcomeMessage = "Architect ready. What are we designing?";
  };

  coder = {
    description = "Implements features and fixes — correct, idiomatic, and scoped to exactly what's asked";
    rules = [
      "tech-stack"
      "dev-environment"
      "refactoring"
      "debugging"
      "response-style"
    ];
    skills = [
      "engineering/tdd"
      "engineering/implement"
      "engineering/codebase-design"
      "engineering/diagnosing-bugs"
      "engineering/resolving-merge-conflicts"
    ];
    bash.autoAllowReadonly = true;
    welcomeMessage = "Coder ready. What are we building?";
  };

  docs = {
    description = "Writes and improves documentation — READMEs, docstrings, changelogs, specs";
    prompt = "docs";
    rules = [ ];
    context = [ "ai-module" ];
    skills = [ "productivity/writing-for-agents" ];
    bash.autoAllowReadonly = true;
    welcomeMessage = "Docs agent ready. What needs writing or improving?";
  };

  git = {
    description = "Manages version control — commits, branches, PRs, and jj operations";
    rules = [ "git-workflow" ];
    skills = [
      "jujutsu"
      "engineering/resolving-merge-conflicts"
      "misc/git-guardrails-claude-code"
    ];
    bash = {
      autoAllowReadonly = true;
      allowedCommands = [
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
    };
    welcomeMessage = "Git/jj agent ready. What needs committing, branching, or pushing?";
  };

  reviewer = {
    description = "Reviews code and PRs — flags issues, suggests improvements, enforces standards";
    rules = [
      "refactoring"
      "debugging"
    ];
    skills = [
      "engineering/code-review"
      "engineering/improve-codebase-architecture"
      "engineering/codebase-design"
    ];
    bash = {
      autoAllowReadonly = true;
      allowedCommands = [
        "jj log.*"
        "jj diff.*"
        "jj show.*"
        "jj status.*"
        "git log.*"
        "git diff.*"
        "git status.*"
        "git show.*"
      ];
    };
    welcomeMessage = "Reviewer ready. Point me at the code or PR.";
  };

  writer = {
    description = "Writes, revises, and refines messages — email, Slack, text, casual";
    prompt = "message-writing";
    rules = [ ];
    skills = [ ];
    tools = [ "read" ];
    welcomeMessage = "Message mode. Paste a draft to revise or refine, or tell me what to write.";
  };

  technical-writer = {
    description = "Writes concise, accurate technical communication — ticket/PR comments, status updates, and summaries of work";
    prompt = "technical-writing";
    rules = [ ];
    skills = [ ];
    bash = {
      autoAllowReadonly = true;
      allowedCommands = [
        "jj log.*"
        "jj diff.*"
        "jj show.*"
        "jj status.*"
        "git log.*"
        "git diff.*"
        "git status.*"
        "git show.*"
      ];
    };
    welcomeMessage = "Technical writing mode. Point me at the work (or paste the details) and say the format — ticket comment, PR, status update, etc.";
  };

  fixer = {
    description = "Delegated fixes — the smallest correct change to resolve a reported issue, nothing beyond it";
    rules = [
      "debugging"
      "refactoring"
      "editing"
    ];
    skills = [ "engineering/diagnosing-bugs" ];
    bash.autoAllowReadonly = true;
    welcomeMessage = "Fixer ready. What's the reported issue?";
  };
}
