# Canonical agent definitions. Tool-neutral: `rules` are steering basenames and
# `skills` is "all" or a list of skill names; adapters map these to each tool's
# resource URIs. Attr key is the agent file/name (override with `name`).
{
  default = {
    prompt = "routing";
    rules = [ "response-style" ];
    skills = "all";
    trustedAgents = [
      "reviewer"
      "git"
      "coder"
      "architect"
      "docs"
      "focused-fix"
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
    skills = "all";
    prompt = "focused-mode";
    welcomeMessage = "Focused mode active. What's the single thing we're fixing?";
  };

  architect = {
    description = "System design, tech decisions, ADRs, and high-level planning";
    rules = [
      "tech-stack"
      "dev-environment"
      "response-style"
    ];
    skills = "all";
    bash.autoAllowReadonly = true;
    welcomeMessage = "Architect ready. What are we designing?";
  };

  coder = {
    description = "Implements features and fixes — focused on correct, complete, idiomatic code";
    rules = [
      "tech-stack"
      "dev-environment"
      "refactoring"
      "debugging"
      "response-style"
    ];
    skills = "all";
    bash.autoAllowReadonly = true;
    welcomeMessage = "Coder ready. What are we building?";
  };

  docs = {
    description = "Writes and improves documentation — READMEs, docstrings, changelogs, specs";
    rules = [ "response-style" ];
    skills = "all";
    bash.autoAllowReadonly = true;
    welcomeMessage = "Docs agent ready. What needs writing or improving?";
  };

  git = {
    description = "Manages version control — commits, branches, PRs, and jj operations";
    rules = [
      "git-workflow"
      "response-style"
    ];
    skills = [ "jujutsu" ];
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
      "response-style"
    ];
    skills = "all";
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
}
