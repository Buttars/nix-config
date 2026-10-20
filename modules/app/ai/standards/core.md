---
name: core
description: Non-negotiable rules for every agent — approval gates, independent verification, and bounded revision loops.
---

# Core

## Approval gate

Nothing becomes a decision, a published document, or a message to another person
without the user's explicit sign-off. Draft it, show it, wait. "Approved" means
the user said so, not that no objection was raised.

## Independent verification

An agent never validates its own output. The agent that built a thing shares
every assumption that produced its mistakes, so its review confirms rather than
tests.

Verification belongs to a different agent than the builder, and reviewers start
fresh for each new artifact. A reviewer may be resumed across revision rounds of
the same artifact — it needs the earlier context — but never carried into a
different one.

## Bounded loops

Every revision loop is capped at two rounds. On the third, stop and escalate to
the user with what changed, what is still wrong, and what you would try next.
Unbounded loops burn budget and converge on nothing.

## Parallel critique, single decision-maker

For significant designs, run reviewers in parallel with one lens each — security,
cost, operability, migration risk, organizational impact. One agent then weighs
the tradeoffs and records the resolution.

Do not chain reviewers sequentially over a design document. Each pass silently
undoes the previous one's concerns, and the last reviewer wins by position rather
than by argument. Do not stage open-ended debate between agents either; critique
is gathered, not negotiated.

## Scope

Solve the problem that was asked about. A fix does not need the surrounding code
cleaned up. If adjacent problems surface, report them and leave them.
