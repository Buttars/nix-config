---
name: editing
description: Efficient edits — read the full region before changing it, group nearby changes into one edit, and confirm the target text exists and differs before writing.
---

# Editing

- Read the full region you intend to change before editing it, not just the target line
- Group nearby changes into a single edit rather than many small sequential ones
- Before writing, confirm the target text exists and differs from the replacement — no no-op edits, no failed matches
