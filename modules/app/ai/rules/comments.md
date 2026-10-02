---
name: comments
description: Comment only to add context the code cannot carry — why it was done this way, never what it does or how it works.
---

# Code Comments

- Default to no comment — code that reads clearly needs none
- Never restate what the code does; if the comment paraphrases the line below it, delete it
- Do not explain how something works — the code is that explanation
- Comment only to record why, and only when the reason lives outside the code and cannot be inferred by reading it
- Reasons that qualify: a non-obvious ordering or timing requirement, a workaround for an upstream bug, a constraint imposed by another system, an alternative that was rejected and why
- Mark an intentional omission when a reader would otherwise "fix" it
- A comment that goes stale the moment the code changes is usually the wrong comment
