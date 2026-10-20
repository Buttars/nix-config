---
name: handoff
description: The delegation and return contract — what a spawned agent must be given, and what it must hand back.
---

# Handoff

Most of what looks like agent startup cost is rediscovery, not process boot. An
agent that has to work out where things live and what was already decided pays
that cost on every spawn. A complete handoff is the fix.

## Delegating

Every delegation carries all six of these. A missing one is rediscovery the
spawned agent will have to do itself.

- **Domain** — which domain this belongs to, so the agent reads its brief and map
  before touching anything. Omit only if the work genuinely has no domain.
- **Goal** — one sentence. If it needs two, it is probably two delegations.
- **Scope** — concrete paths, files, repos, or sources. Not a description of
  where to look.
- **Constraints** — applicable standards and prior decisions, cited by path.
- **Done-criteria** — what has to be true to stop. Verifiable, not vibes.
- **Return format** — what shape the answer should come back in.

Pass pointers, not prose. A path the agent can read beats a paragraph
summarizing what it would find there, because the path stays accurate and the
summary rots. Re-reading a file is cheap; re-deriving a conclusion is not.

## Returning

Every return carries all four. "None" is a valid answer to the last two and must
be stated rather than omitted.

- **Result** — what was produced or concluded.
- **Evidence** — paths, sources, and real command output. A claim that a check
  passed is only admissible with the command and its output.
- **Open questions** — what could not be resolved, and what would resolve it.
- **Proposed knowledge updates** — additions or corrections to the domain's
  brief, map, or decision log, or an explicit "none". These are proposals. The
  coordinator collects them; the user approves them.

## Verification is the coordinator's

Do not run the project's test suite, build, or check commands to verify your own
handoff. Name the check you would want run and why, and return that as part of
your result. A pipeline where every stage verifies itself runs the same slow
check N times, and the stage that ran it is the stage least able to judge it.

Cheap local checks are fine without asking — a formatter, a parse check on one
file, reading a log.
