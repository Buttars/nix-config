# AI Module — Shared Vocabulary

Canonical terms for the `modules/app/ai/` system. Use these consistently in
code, docs, prompts, commit messages, and agent conversations. Where a term has
common synonyms, the preferred term is listed first; alternatives to avoid are
noted explicitly.

---

## Core concepts

**Rule**
A steering file that shapes agent behavior. Loaded as always-on context.
Stored as `rules/<name>.md`; rendered to `~/.kiro/steering/<name>.md` by the
Kiro adapter. Agents declare which rules they load by name; global inheritance
also makes all rules visible to every agent unless disabled.
_Avoid_: guideline, instruction, policy, constraint

**Prompt**
A system prompt that defines an agent's identity and behavioral mode. Stored as
`prompts/<name>.md`. Each agent has at most one prompt; agents without a prompt
rely on the tool's built-in identity.
_Avoid_: system prompt (too implementation-specific), command (that's a slash command)

**Agent**
A named configuration that bundles a prompt, a set of rules, a skill scope, a
tool allowlist, and invocation settings. Defined as an attribute in
`_agents.nix`; rendered to `~/.kiro/agents/<name>.json` by the Kiro adapter.
_Avoid_: assistant, persona, bot, mode

**Skill**
A named, on-demand behavior the agent can invoke — a slash command plus its
procedure. Stored as `<category>/<name>/SKILL.md` with YAML frontmatter
(`name`, `description`). Loaded lazily: the description is always in context;
the full body loads when the skill is activated. Skills come from two sources:
the external `agent-skills-nix` bundle (Matt Pocock's skills), and this repo's
first-party `skills/` directory.
_Avoid_: command (use only when talking about the slash command invocation), tool
(that's a Kiro/LLM tool call)

**Dispatcher**
The `default` agent. Routes clearly-specialized work to specialists via
`trustedAgents`; handles everything else itself. The routing table lives in its
prompt (`routing.md`). There is exactly one dispatcher.
_Avoid_: router, orchestrator, coordinator

**Specialist**
Any agent in the dispatch graph other than the dispatcher: `reviewer`, `git`,
`coder`, `architect`, `docs`, `focused-fix`. Spawned by the dispatcher as a
subagent for clearly-scoped work; can also be switched to directly.
_Avoid_: sub-agent (that's a runtime concept, not an agent type)

**Switch-to agent**
An agent outside the dispatch graph — invoked only by explicit `/agent <name>`.
Not spawnable by the dispatcher. Currently: `writer`, `technical-writer`.
_Avoid_: standalone agent, direct agent

---

## Invocation

**User-invoked skill**
A skill reachable only when the user types the slash command. Its job is to
orchestrate. May invoke model-invoked skills; never invokes another user-invoked
skill.
Example: `/grill-me`, `/code-review`

**Model-invoked skill**
A skill the agent can reach for automatically when the task fits, without the
user typing it. Holds reusable discipline. May be invoked by the user directly
or reached by a user-invoked skill.
Example: `grilling`, `tdd`, `prototype`

**Subagent**
A specialist spawned at runtime inside a response, by the dispatcher or by a
skill. Not an agent definition — it's a call. Subagents run in parallel or in
sequence depending on whether they have `depends_on` edges.
_Avoid_: agent (reserve for the definition), sub-task

---

## Configuration model

**`_agents.nix`**
The canonical agent data file. Underscore-prefixed so flake-parts/den does not
auto-import it as an aspect. The single source of truth for all agent
definitions; adapters read this and render into tool-specific formats.

**Adapter**
A Nix module that reads the canonical data (`_agents.nix`, `rules/`, `prompts/`)
and renders it into the format a specific AI tool expects. The Kiro adapter
(`default.nix`) is the only adapter currently implemented. Adding a tool means
writing a new adapter; the canonical data does not change.
_Avoid_: renderer, plugin, integration

**Target**
A specific AI tool an adapter renders for. Current target: Kiro CLI.
Planned targets: opencode, Claude Code, Cursor, Codex.
_Avoid_: tool (overloaded — use "target" for the destination AI tool)

**Rule scope**
Which rules an agent loads. Declared as a list of rule basenames in
`_agents.nix`. Kiro's global inheritance also injects all rules into every
agent; set `chat.disableInheritingDefaultResources true` to restrict to declared
rules only.

**Skill scope**
Which skills an agent loads. Either `"all"` (both the bundle globs) or a list of
skill names. `[]` means no skills.

---

## Source locations

| Concept             | Source path                    | Rendered to (Kiro)                     |
| ------------------- | ------------------------------ | -------------------------------------- |
| Rule                | `rules/<name>.md`              | `~/.kiro/steering/<name>.md`           |
| Prompt              | `prompts/<name>.md`            | `~/.kiro/prompts/<name>.md`            |
| Agent               | `_agents.nix` entry            | `~/.kiro/agents/<name>.json`           |
| Skill (first-party) | `skills/<cat>/<name>/SKILL.md` | `~/.kiro/skills/<cat>/<name>/SKILL.md` |
| Skill (bundle)      | `agent-skills-nix` flake       | `~/.kiro/skills/<cat>/<name>/SKILL.md` |

---

## Relationships

- A **dispatcher** holds a routing table and a `trustedAgents` list of specialists.
- A **specialist** declares rules, a prompt, a skill scope, and a tool allowlist.
- A **skill** is loaded into an agent's context based on its skill scope; it
  activates when invoked (user-invoked) or when the agent judges it applicable
  (model-invoked).
- An **adapter** renders all three (rules, prompts, agents) for one target from
  one canonical source.
- A **subagent** is an agent spawned at runtime — not a definition, a call.

---

## Flagged ambiguities

- **"tool"** is overloaded: it means a Kiro/LLM function call (read, write,
  shell, etc.) and colloquially refers to an AI coding tool (Kiro, Claude Code).
  Resolved: use **target** for the AI coding application, and **tool** only for
  LLM-callable functions.
- **"command"** can mean a slash command (e.g. `/grill-me`) or a bash command.
  Resolved: use **skill** for slash-command behaviors; **command** only in the
  context of bash/shell invocation.
- **"rule" vs "steering"**: the Kiro format calls these steering files; this
  module calls them rules (tool-neutral). Resolved: **rule** in all source and
  doc references; "steering" only when referring to the Kiro-specific rendered
  path (`~/.kiro/steering/`).
- **"prompt" vs "system prompt"**: some docs say system prompt. Resolved: always
  **prompt** here; "system prompt" is implementation detail.
