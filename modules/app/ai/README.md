# ai

Canonical, tool-neutral source for the AI assistant configuration. Content lives
here once; a per-tool adapter renders it into the locations each tool expects.
Today the only adapter targets Kiro CLI.

## Layout

- `rules/*.md` — steering rules (tone, workflow, tech defaults). Plain markdown,
  tool-neutral.
- `prompts/*.md` — agent system prompts: `routing.md` (dispatcher),
  `message-writing.md` (writer), `focused-mode.md`.
- `_agents.nix` — agent definitions as data. Underscore-prefixed because
  flake-parts/den auto-imports every non-`_` `.nix` under `modules/` as an
  aspect; the prefix keeps this a plain data file, not an aspect.
- `default.nix` — the `aegix.ai` adapter. Reads `_agents.nix` and renders the
  Kiro files.
- `skills/` — placeholder for first-party skills in the
  `<category>/<name>/SKILL.md` convention. Installed skills currently come from
  the external `agent-skills-nix` bundle, not this module.

## What the adapter renders (Kiro)

- `rules/` → `~/.kiro/steering/` (in-store symlink; always-on context)
- `prompts/` → `~/.kiro/prompts/` (in-store symlink)
- each agent in `_agents.nix` → `~/.kiro/agents/<name>.json`
- `~/.kiro/skills/` is provided by `agent-skills-nix`, independent of this module

Because the symlinks are in-store, edits take effect on rebuild, not live.

## Agent data model (`_agents.nix`)

The attribute key is the agent name and JSON filename (override with `name`).

- `rules` — rule basenames, mapped to `file://~/.kiro/steering/<rule>.md`
- `skills` — `"all"` (both skill globs) or a list of skill names; `[]` for none
- `prompt` — prompt basename, mapped to `file://../prompts/<name>.md`
- `tools` — tool list (defaults to `["*"]`)
- `bash` — `{ autoAllowReadonly; allowedCommands; }` → `toolsSettings.execute_bash`
- `trustedAgents` — agents this one may spawn → `toolsSettings.crew.trustedAgents`
- `description`, `welcomeMessage` — optional

## Dispatcher pattern

`default` is the dispatcher: its prompt is `routing.md` (a delegation table) and
it lists the specialists in `trustedAgents`. For clearly-specialized work it
spawns the matching specialist as a subagent and folds the result back; small or
ambiguous requests it handles itself. Delegation is model-driven and best-effort,
not a hard router.

Specialists (`reviewer`, `git`, `coder`, `architect`, `docs`, `focused-fix`) each
declare a curated subset of rules, their own tools, and where relevant a bash
allow-list. Routing lives only on the dispatcher's prompt, so specialists do not
carry it.

`writer` is deliberately outside the dispatch graph — it is switch-to only
(`/agent writer`) because its Draft/clarify flow needs a direct conversation. It
has read-only tools and three modes: Revise, Refine, Draft.

Note: Kiro auto-inherits global steering into every custom agent by default, so
specialists also see all `rules/` regardless of what they declare. Set
`chat.disableInheritingDefaultResources` to limit each agent to only its declared
resources.

## Adding things

- Rule: add `rules/<name>.md`; reference it from an agent's `rules`, or rely on
  global inheritance.
- Agent: add an entry to `_agents.nix`; put its prompt in `prompts/` if it needs
  one.
- Activation: the module is included via `<aegix/ai>`; changes apply on rebuild
  and `darwin-rebuild switch`.

## Extraction

The tree keeps content self-contained and uses the `SKILL.md` convention so it
can be split into a standalone repo later (`git subtree split`). `default.nix` is
the nix-config-specific glue that would stay behind.
