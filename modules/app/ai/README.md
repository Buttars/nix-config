# ai

Canonical, tool-neutral source for the AI assistant configuration. Content lives
here once; a per-tool adapter renders it into the locations each tool expects.
Today the only adapter targets Kiro CLI.

## Layout

- `rules/*.md` — steering rules (tone, workflow, tech defaults). Plain markdown,
  tool-neutral.
- `prompts/*.md` — agent system prompts: `routing.md` (dispatcher), `docs.md`,
  `technical-writing.md`, `message-writing.md`, `writing.md`, `focused-mode.md`
  (shared by `focused-fix` and `fixer`).
- `context/*.md` — domain vocabulary and shared context documents. Not behavioral
  rules — these define the terms and architecture so agents use consistent
  language. Loaded per-agent via the `context` field in `_agents.nix`.
- `_agents.nix` — agent definitions as data. Underscore-prefixed because
  flake-parts/den auto-imports every non-`_` `.nix` under `modules/` as an
  aspect; the prefix keeps this a plain data file, not an aspect.
- `default.nix` — the `aegix.ai` adapter. Reads `_agents.nix` and renders the
  Kiro files.
- `skills/` — placeholder for first-party skills in the
  `<category>/<name>/SKILL.md` convention. Installed skills currently come from
  the external `agent-skills-nix` bundle, not this module.

## Knowledge lives elsewhere

This module covers how agents _behave_. What they _know_ about a given domain —
briefs, orientation maps, decision logs, research threads — lives in a separate
repo at `~/.config/ai-knowledge`, outside this config. It is data rather than
configuration: it changes constantly, has no bearing on machine state, and is
not versioned with the system.

`default.nix` creates that directory at activation and manages nothing inside
it, so edits take effect immediately instead of on rebuild. See the README there
for what makes a domain and what the three per-domain files are for.

## What the adapter renders (Kiro)

- `rules/` → `~/.kiro/steering/` (in-store symlink; always-on context)
- `prompts/` → `~/.kiro/prompts/` (in-store symlink)
- each agent in `_agents.nix` → `~/.kiro/agents/<name>.json`
- `~/.kiro/skills/` is provided by `agent-skills-nix`, independent of this module

Because the symlinks are in-store, edits take effect on rebuild, not live.

## Agent data model (`_agents.nix`)

The attribute key is the agent name and JSON filename (override with `name`).

- `name` — overrides the agent name when it must differ from the attribute key
- `rules` — rule basenames, mapped to `file://~/.kiro/steering/<rule>.md`.
  `default.rules` is the universal baseline: the adapter merges it into every
  agent, so each agent lists only the rules it adds on top.
- `context` — context doc basenames, mapped to `file://~/.kiro/context/<name>.md`
- `skills` — `"all"` (both skill globs) or a list of skill names; `[]` for none
- `prompt` — prompt basename, mapped to `file://../prompts/<name>.md`
- `tools` — tool list (defaults to `["*"]`)
- `bash` — `{ autoAllowReadonly; allowedCommands; }` → `toolsSettings.execute_bash`
- `trustedAgents` — agents this one may spawn → `toolsSettings.crew.trustedAgents`
- `mcpServers` — server names from `_mcp.nix`; defaults to all of them, `[]` for
  none
- `hooks` — Kiro hooks, e.g. `agentSpawn` to seed `.kiro/notes.md` into context
- `description`, `welcomeMessage` — optional

## Dispatcher pattern

`default` is the dispatcher: its prompt is `routing.md` (a delegation table) and
it lists the specialists in `trustedAgents`. For clearly-specialized work it
spawns the matching specialist as a subagent and folds the result back; small or
ambiguous requests it handles itself. Delegation is model-driven and best-effort,
not a hard router.

Specialists (`reviewer`, `version-control`, `coder`, `architect`, `docs`,
`fixer`, `message-writer`, `writing`, `technical-writer`) each
declare a curated subset of rules, their own tools, and where relevant a bash
allow-list. Routing lives only on the dispatcher's prompt, so specialists do not
carry it.

`focused-fix` is deliberately outside the dispatch graph — it is switch-to only
(`/agent focused-fix`), a user-invoked mode rather than a delegation target.
`fixer` is the delegated fix lane and shares its prompt.

`message-writer` is a specialist with read-only tools and three modes — Revise,
Refine, Draft — so it reworks a pasted draft without touching the repo.

Note: Kiro auto-inherits global steering into every custom agent by default,
which would make these per-agent `rules` lists cosmetic. `modules/app/kiro.nix`
sets `chat.disableInheritingDefaultResources` at activation, so each agent loads
only `default.rules` plus what it declares.

## Adding things

- Rule: add `rules/<name>.md`; reference it from an agent's `rules`, or rely on
  global inheritance.
- Context doc: add `context/<name>.md`; reference it from an agent's `context`
  list. Use for vocabulary and domain knowledge, not behavioral instructions.
- Agent: add an entry to `_agents.nix`; put its prompt in `prompts/` if it needs
  one.
- Activation: the module is included via `<aegix/ai>`; changes apply on rebuild
  and `darwin-rebuild switch`.

## Extraction

The tree keeps content self-contained and uses the `SKILL.md` convention so it
can be split into a standalone repo later (`git subtree split`). `default.nix` is
the nix-config-specific glue that would stay behind.
