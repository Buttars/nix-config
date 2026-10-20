# Plan: multi-tool agent & prompt configuration

Future work to generalize this `ai/` module from "Kiro + a hand-rolled opencode
adapter" into a canonical, tool-neutral source of agent/prompt configuration
with per-tool **adapters**. Not yet implemented — this is the roadmap.

## Goal

One canonical definition of **agents**, **rules/steering**, and
**prompts/commands**, rendered into each tool's native format (Kiro, opencode,
Claude Code, Cursor, Codex, …). Skills are already handled by `agent-skills-nix`
and stay there; this plan covers everything _except_ skills.

## Current state

- `ai/rules/*.md` — canonical steering (6 rules).
- `ai/prompts/*.md` — agent system prompts (`routing`, `focused-mode`, `message-writing`).
- `ai/_agents.nix` — canonical agent data (`_`-prefixed so den/flake-parts does
  not import it as an aspect).
- `modules/app/ai/default.nix` — the **Kiro adapter**: renders steering →
  `~/.kiro/steering`, prompts → `~/.kiro/prompts`, agents → `~/.kiro/agents/*.json`.
- `modules/app/opencode.nix` — a **hand-rolled opencode adapter**: `instructions`
  (steering), `agent` config (agents), plus the Kiro-provider plumbing
  (`OPENCODE_DISABLE_MODELS_FETCH`, models-dev graft). Uses raw
  `xdg.configFile`, not the `programs.opencode` module.
- `agent-skills-nix` (`modules/app/skills.nix`) — skills only; dedicated per-tool
  `skills/` dirs with a `.agent-skills-managed.json` ownership marker.

## Target architecture

### 1. Canonical schema (superset)

Tool-neutral data with an abstract invocation intent; adapters map/degrade.

```
agents.<name> = {
  description;                       # always (Claude routes on it, others show it)
  prompt;                            # optional (path/lines)
  invocation = "primary"|"delegate"|"both";
  tools = { allow = [...]; autoApprove = [...]; };
  resources = [ "rule-name" ... ];   # per-agent context (Kiro); degrade elsewhere
  model;                             # optional
  delegatesTo = [ ... ];             # composition (Kiro crew, etc.)
  raw.<tool> = { ... };              # per-tool escape hatch (verbatim passthrough)
};
rules.<name>  = { body; globs?; alwaysApply?; };
prompts.<name> = { body; };          # slash commands / named prompts
```

### 2. Adapter registry + capabilities

```
adapters.<tool> = {
  capabilities = { perAgentResources; routing; trust; ... };
  render = { agents, rules, prompts }: [ outputs ];   # see output model
};
```

Adding a tool = one registration; the core never changes. Capabilities let each
adapter declare what it supports so "lossy" edges become explicit policy (map,
inline, or drop+warn) rather than blockers.

### 3. Integration / output modes (pick per tool)

- **HM module with mergeable options** (preferred where it exists): write to
  `programs.<tool>.*`. home-manager merges across modules, so ownership and the
  single-shared-config-file problem disappear. opencode is the model case:
  - `programs.opencode.settings` (mergeable `opencode.json`)
  - `programs.opencode.agents.<name>` → `agents/<name>.md`
  - `programs.opencode.context` → `AGENTS.md`
  - `programs.opencode.commands`, `.skills`, `.tui`
- **No HM module** → emit files directly (`home.file`/`xdg.configFile`), or a
  dir + ownership marker (agent-skills-nix style) for whole-directory targets.
  Kiro is here (render JSON via `home.file`).
- **File-form over config-merge**: most tools accept agents as files in a
  dedicated dir (Kiro `agents/*.json`, Claude `agents/*.md`, opencode
  `agents/*.md`). Prefer that to merging into a shared config file.

### 4. Invocation & trust mapping

- `invocation`: Kiro → switch-to / `crew.trustedAgents`; opencode → `mode`
  (primary/subagent/all); Claude → subagent (auto-routed by `description`).
- `tools`: canonical `allow`/`autoApprove` → Kiro `toolsSettings`
  (path/command granularity), opencode `tools` + `permission`, Claude flat
  allowlist. Downgrade to each tool's ceiling.

## Per-tool mapping matrix

|          | Kiro                                | opencode                                                              | Claude Code               | Cursor                                    |
| -------- | ----------------------------------- | --------------------------------------------------------------------- | ------------------------- | ----------------------------------------- |
| agent    | `~/.kiro/agents/<n>.json` (file)    | `programs.opencode.agents.<n>` → `agents/<n>.md`                      | `~/.claude/agents/<n>.md` | —                                         |
| rules    | `~/.kiro/steering/*.md` (resources) | `programs.opencode.context` → `AGENTS.md`, or `settings.instructions` | `CLAUDE.md`/`@import`     | `.cursor/rules/*.mdc` (frontmatter globs) |
| commands | `~/.kiro/prompts/*.md`              | `programs.opencode.commands`                                          | `~/.claude/commands/*.md` | —                                         |
| skills   | agent-skills-nix                    | agent-skills-nix (`targets.opencode`)                                 | agent-skills-nix          | agent-skills-nix                          |

## Phased implementation

- **Phase 0 — opencode onto its HM module (quick win).** Replace the raw
  `xdg.configFile` in `opencode.nix` with `programs.opencode`
  (`settings` + `context` + `agents`). Merge-safe; removes hand-rolled JSON.
- **Phase 1 — formalize the canonical schema.** Turn `_agents.nix` (+ new
  `rules`/`prompts` data) into a documented options schema in `ai/`.
- **Phase 2 — adapter interface + registry.** Define `adapters.<tool>` and port
  the existing Kiro + opencode renderers behind it (they're the two hardest and
  already proven).
- **Phase 3 — capabilities + escape hatches.** Add capability declarations,
  degradation policy (inline/drop/warn), and `raw.<tool>` passthrough.
- **Phase 4 — more adapters.** Claude Code, Cursor, Codex (`AGENTS.md`).
- **Phase 5 — extract to a standalone flake (optional).** `agent-config-nix`,
  the agents/rules sibling to `agent-skills-nix`; reusable across configs.
- **Phase 6 — upstream.** File/land the feature request on `agent-skills-nix`
  (expand beyond skills) or publish Phase 5 as the community solution.

## Design decisions & constraints

- **Render, don't copy.** Agents/rules are heterogeneous per tool; a copy model
  (like skills) does not work. Adapters transform.
- **Prefer mergeable HM options, then file-form, then config-merge.** This is
  the ordering that avoids home-manager single-owner-file conflicts.
- **Don't duplicate skills.** Keep them in `agent-skills-nix`; just enable
  `targets.opencode` there if opencode should get skills too.
- **Lossy = declared.** A missing capability is an adapter policy, not a bug.

## Open questions / risks

- Per-tool format churn is the real long-tail cost (opencode's format already
  shifted once mid-setup). Adapters need maintenance as tools evolve.
- Testing renders _structure_ is easy; testing runtime _behavior_ per tool is
  manual (cf. the opencode Kiro-provider debugging).
- Config-merge tools without an HM module would still need an ownership story;
  none currently in scope.

## References

- `modules/app/ai/README.md` — current module (Kiro adapter, dispatcher).
- `modules/app/skills.nix` — `agent-skills-nix` usage (skills).
- home-manager `programs.opencode` — `settings`/`agents`/`context`/`commands`/`skills`.
- Feature request draft (expand `agent-skills-nix` beyond skills) — see chat history.
