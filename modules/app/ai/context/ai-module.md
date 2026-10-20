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

**Standard**
Protocol every agent follows, as distinct from a rule, which is scoped. Stored
as `standards/<name>.md`; rendered to `~/.kiro/standards/<name>.md`. Three exist:
`core` (approval gates, independent verification, bounded loops), `handoff` (the
delegation and return contract), `session` (orient, checkpoint, retire). The test
for whether something is a standard rather than a rule: if one agent opting out
would break another agent, it is a standard.
_Avoid_: protocol (use for the thing a standard describes, not the file), rule

**Template**
A skeleton for an artifact a standard refers to — brief, map, decisions, ADR,
findings. Stored as `standards/templates/<name>.md`. Referenced on demand by
whoever is writing the artifact; never loaded as context.

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
Any agent in the dispatch graph other than the dispatcher — the members of the
dispatcher's `trustedAgents`: `reviewer`, `version-control`, `coder`,
`architect`, `docs`, `fixer`, `message-writer`, `writing`,
`technical-writer`. Spawned by the dispatcher as a subagent for clearly-scoped
work; can also be switched to directly. `architect` additionally holds its own
`trustedAgents`, so the graph is not a single layer.
_Avoid_: sub-agent (that's a runtime concept, not an agent type)

**Switch-to agent**
An agent outside the dispatch graph — invoked only by explicit `/agent <name>`.
Not spawnable by the dispatcher. Currently: `focused-fix`, the user-invoked
counterpart to the delegated `fixer` lane.
_Avoid_: standalone agent, direct agent

**Grounding**
Whether the work has an external source of truth to verify against — code, a
diff, a running system — or whether the user is the only source. Grounded output
can be checked against the thing it describes; ungrounded output can only be
confirmed with the user, which is why voice preservation and flagging missing
facts matter there.
_Avoid_: factual, sourced, accurate

**Durability**
Whether output is re-read later or consumed once. Durable output (a README, an
essay) must stand alone for a reader who was not in the room. Ephemeral output
(a ticket comment, a Slack message) is read once, in a context both parties
already share.
_Avoid_: permanence, longevity, lifespan

Grounding crossed with durability names the four writing agents:

|            | durable   | ephemeral          |
| ---------- | --------- | ------------------ |
| grounded   | `docs`    | `technical-writer` |
| ungrounded | `writing` | `message-writer`   |

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

**Capability**
An abstract permission an agent holds, named for what it does rather than for
the tool that does it: `read`, `search`, `code`, `edit`, `shell`, `web`, `spawn`,
`aws` for tools, and `forge`, `docs`, `tickets`, `infra`, `flags`, `terminal`,
`files` for MCP server groups. Declared in `_agents.nix`, resolved by
`_mappings.nix`. Agents never name a concrete tool.
_Avoid_: permission, tool (a capability may map to several tools)

**Tier**
A model class rather than a model: `strong` or `fast`. Declared per agent,
resolved to a model id by `_mappings.nix`, so changing which model backs a tier
is one edit in one file.
_Avoid_: model (reserve for the concrete id)

**`_mappings.nix`**
The translation layer. Maps capabilities to concrete tool names, tiers to model
ids, and MCP groups to `_mcp.nix` server names. The only file that knows a
harness's vocabulary, which is what keeps `_agents.nix` neutral.

**Adapter**
A Nix module that reads the canonical data (`_agents.nix`, `rules/`,
`standards/`, `prompts/`) and renders it into the format a specific AI tool
expects, using `_mappings.nix` to resolve abstract names. The Kiro adapter
(`default.nix`) is the only adapter currently implemented. Adding a tool means a
new adapter and a new mapping; the canonical data does not change.
_Avoid_: renderer, plugin, integration

**Target**
A specific AI tool an adapter renders for. Current target: Kiro CLI.
Planned targets: opencode, Claude Code, Cursor, Codex.
_Avoid_: tool (overloaded — use "target" for the destination AI tool)

**Rule scope**
Which rules an agent loads. Declared as a list of rule basenames in
`_agents.nix`, and enforced: `modules/app/kiro.nix` sets
`chat.disableInheritingDefaultResources`, which turns off Kiro's global
inheritance so an agent receives only `default.rules` plus its own declarations.

Standards have no equivalent scope. Every agent gets `default.standards`,
because a standard only one side of a handoff follows is not a protocol.

**Skill scope**
Which skills an agent loads. Either `"all"` (both the bundle globs) or a list of
skill names. `[]` means no skills.

---

## Source locations

| Concept             | Source path                         | Rendered to (Kiro)                     |
| ------------------- | ----------------------------------- | -------------------------------------- |
| Rule                | `rules/<name>.md`                   | `~/.kiro/steering/<name>.md`           |
| Standard            | `standards/<name>.md`               | `~/.kiro/standards/<name>.md`          |
| Template            | `standards/templates/<name>.md`     | not rendered; read on demand           |
| Prompt              | `prompts/<name>.md`                 | `~/.kiro/prompts/<name>.md`            |
| Agent               | `_agents.nix` entry                 | `~/.kiro/agents/<name>.json`           |
| Skill (first-party) | `skills/<cat>/<name>/SKILL.md`      | `~/.kiro/skills/<cat>/<name>/SKILL.md` |
| Skill (bundle)      | `agent-skills-nix` flake            | `~/.kiro/skills/<cat>/<name>/SKILL.md` |
| Knowledge           | `~/.config/ai-knowledge` (own repo) | read in place, not nix-managed         |

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
- **`docs` vs `writing`**: both produce durable documents, so the name alone does
  not separate them. Resolved: they differ only by **grounding** — `docs` writes
  against code or a system it can read and verify; `writing` writes where the
  user is the only source and the thing to protect is their voice.
