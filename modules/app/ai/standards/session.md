---
name: session
description: Session lifecycle for the coordinator — orient from files, checkpoint before stopping, start fresh across days.
---

# Session

Two kinds of persistence, with different lifetimes. Durable knowledge — what is
true, what was decided, where things live — lasts weeks and belongs in files.
Work-in-progress reasoning only needs to survive until it is written down.
Confusing the two is how findings get lost.

Knowledge lives in `~/.config/ai-knowledge`. See its README for what a domain is
and what each file holds.

## Start

Identify the domain. Read its `brief.md` and `map.md` before exploring; that is
what they exist for. If the domain has no brief yet, say so — working without one
is a choice, not a default.

## During

Findings accumulate in `.kiro/notes.md`, a scratch file shared across agents in
the working directory and read in when an agent spawns. It is the work-in-progress
tier, not the durable one: it is gitignored and dies with the checkout.

- Append what would otherwise have to be rediscovered. Do not restate the task.
- Every factual claim carries a `file:line` citation.
- Mark each claim `verified:` (you ran it or read it) or `inferred:` (reasoned,
  untested). Never promote an `inferred:` claim without re-checking it.
- Record conclusions and dead ends, not file contents.
- Write nothing if nothing would need rediscovering.

Scratch notes go stale silently. A note describing code that no longer exists is
worse than no note, because it is read with the same confidence as a true one. If
a claim contradicts what you observe, trust the observation and correct the note.

## Checkpoint

Before stopping, and before any agent approaches its context limit:

1. Collect the proposed knowledge updates from every agent that worked.
2. Present them to the user as a set, grouped by target file.
3. Commit the approved ones to the knowledge repo. Leave the rest.

This step is what makes the system work. It converts reasoning that exists only
in a session into knowledge that outlives it. Skipping it means the next session
rediscovers everything, and the scratch file accumulates claims nobody promoted.

Never write student records, PII, credentials, or FERPA-protected information
into a knowledge file, a handoff, or the scratch file. Knowledge describes
systems, not people.

## Across days

Start fresh from the files. Do not depend on session or sub-agent resume handles
surviving overnight or across context summarization — they often do not, and the
fallback is only cheap when the brief and map are current. Which is the argument
for checkpointing, not for trusting resume.

## Retirement

An agent nearing its context limit should retire before compaction rather than
after. Compaction discards the reasoning that has not been written down yet, so
checkpoint first, then start a successor from the files. Expect architecture and
research agents to need retiring sooner than development agents — their context
is dense reasoning rather than re-readable file contents.
