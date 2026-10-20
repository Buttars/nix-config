# ai

Canonical, tool-neutral source for the AI assistant configuration. Content lives
here once; a per-tool adapter renders it into the locations each tool expects.
Today the only adapter targets Kiro CLI.

## Layout

- `rules/*.md` — steering rules (tone, workflow, tech defaults). Scoped per
  agent. Plain markdown, tool-neutral.
- `standards/*.md` — protocol every agent follows: `core.md` (approval gates,
  independent verification, bounded loops), `handoff.md` (the delegation and
  return contract), `session.md` (orient, checkpoint, retire). Unlike rules these
  are not scoped — an agent that opts out of the handoff contract breaks the
  agents it hands off to.
- `standards/templates/*.md` — skeletons for the artifacts the standards refer
  to: brief, map, decisions, ADR, findings. Referenced on demand, never loaded as
  context.
- `prompts/*.md` — agent system prompts: `routing.md` (dispatcher), `docs.md`,
  `technical-writing.md`, `message-writing.md`, `writing.md`, `research.md`,
  `ticketing.md`, `focused-mode.md` (shared by `focused-fix` and `fixer`).
- `context/*.md` — domain vocabulary and shared context documents. Not behavioral
  rules — these define the terms and architecture so agents use consistent
  language. Loaded per-agent via the `context` field in `_agents.nix`.
- `_agents.nix` — agent definitions as data. Underscore-prefixed because
  flake-parts/den auto-imports every non-`_` `.nix` under `modules/` as an
  aspect; the prefix keeps this a plain data file, not an aspect.
- `_mappings.nix` — translates the abstract capability, MCP group, and tier names
  used in `_agents.nix` into Kiro tool names, `_mcp.nix` server names, and model
  ids. The only file that holds a harness's vocabulary.
- `_mcp.nix` — MCP server definitions, shared with `modules/app/kiro.nix`.
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
- `standards/` → `~/.kiro/standards/` (in-store symlink)
- `prompts/` → `~/.kiro/prompts/` (in-store symlink)
- each agent in `_agents.nix` → `~/.kiro/agents/<name>.json`
- `~/.kiro/skills/` is provided by `agent-skills-nix`, independent of this module

Because the symlinks are in-store, edits take effect on rebuild, not live.

Resources are emitted standards-first, then rules, context, and skills, so the
stable part of the context window sits ahead of the parts most likely to change.

## Agent data model (`_agents.nix`)

The attribute key is the agent name and JSON filename (override with `name`).

- `name` — overrides the agent name when it must differ from the attribute key
- `standards` — standard basenames, mapped to
  `file://~/.kiro/standards/<name>.md`. `default.standards` is the universal
  baseline, merged into every agent.
- `rules` — rule basenames, mapped to `file://~/.kiro/steering/<rule>.md`.
  `default.rules` is the universal baseline: the adapter merges it into every
  agent, so each agent lists only the rules it adds on top.
- `context` — context doc basenames, mapped to `file://~/.kiro/context/<name>.md`
- `skills` — `"all"` (both skill globs) or a list of skill names; `[]` for none
- `prompt` — prompt basename, mapped to `file://../prompts/<name>.md`
- `tier` — `"strong"` or `"fast"`; resolved to a model id. Omit to inherit
  `chat.defaultModel`.
- `tools` — abstract capabilities: `read`, `search`, `code`, `edit`, `shell`,
  `web`, `spawn`, `aws`. Resolved to concrete tool names, plus `baseTools` which
  every agent gets. Omit for `baseTools` only.
- `mcp` — abstract server groups: `forge`, `docs`, `tickets`, `infra`, `flags`,
  `terminal`, `files`. Omit for none.
- `approveReadonlyShell`, `approvedCommands` → `toolsSettings.execute_bash`.
  Note that `approvedCommands` has no effect headlessly; kiro-cli denies shell
  non-interactively whatever the allowlist says.
- `trustedAgents` — agents this one may spawn → `toolsSettings.crew.trustedAgents`
- `hooks` — Kiro hooks, e.g. `agentSpawn` to seed `.kiro/notes.md` into context
- `description`, `welcomeMessage` — optional

Capability and tier names mean nothing on their own; `_mappings.nix` is the only
place they become Kiro tool names, model ids, and `_mcp.nix` server names.
Retargeting is a sibling mapping plus a sibling renderer, not an edit to any
agent.

## Capability scoping

Capabilities are granted where a role needs them, not everywhere, because tool
and MCP server definitions dominate an agent's starting context. Two of the
narrowings carry meaning beyond cost:

- `reviewer` has no `edit`. `standards/core.md` requires review and authorship to
  live in different agents, and withholding the tool is what enforces it rather
  than asking the agent not to.
- `architect` has `spawn` and its own `trustedAgents`. Parallel critique under a
  single decision-maker only works if the agent holding the decision can spawn
  the critics.

## Dispatcher pattern

`default` is the dispatcher: its prompt is `routing.md` (a delegation table) and
it lists the specialists in `trustedAgents`. For clearly-specialized work it
spawns the matching specialist as a subagent and folds the result back; small or
ambiguous requests it handles itself. Delegation is model-driven and best-effort,
not a hard router.

Specialists (`reviewer`, `version-control`, `coder`, `architect`, `docs`,
`fixer`, `message-writer`, `writing`, `technical-writer`, `researcher`,
`ticketer`) each declare a curated subset of rules, their own capabilities, and
where relevant a shell allow-list. Routing lives only on the dispatcher's prompt,
so specialists do not carry it.

`researcher` is read-only by capability, not just by instruction — it has no
`edit`, so "gathers evidence, does not change things" is enforced rather than
asked for. `ticketer` works only from an approved plan and preserves its scope
exactly; its prompt is mostly a list of things it must not change.

`focused-fix` is deliberately outside the dispatch graph — it is switch-to only
(`/agent focused-fix`), a user-invoked mode rather than a delegation target.
`fixer` is the delegated fix lane and shares its prompt.

`message-writer` is a specialist with read-only tools and three modes — Revise,
Refine, Draft — so it reworks a pasted draft without touching the repo.

Note: Kiro auto-inherits global steering into every custom agent by default,
which would make these per-agent `rules` lists cosmetic. `modules/app/kiro.nix`
sets `chat.disableInheritingDefaultResources` at activation, so each agent loads
only the baseline plus what it declares.

## Adding things

- Rule: add `rules/<name>.md` and reference it from an agent's `rules`, or from
  `default.rules` if every agent needs it. Nothing is inherited implicitly.
- Standard: add `standards/<name>.md` and add it to `default.standards`. A
  standard that only some agents follow is a rule, not a standard.
- Template: add `standards/templates/<name>.md` and reference it from whichever
  standard calls for the artifact. Templates are not loaded as context.
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
