---
name: verification
description: Verification discipline — never run test suites, builds, or check commands unprompted; report what was left unverified instead of resolving it unilaterally.
---

# Verification

- Never run test suites, build validation, or check commands unprompted — ask first and run only what is approved
- This includes `nix flake check`, full test suites, and any long-running validation
- Cheap, fast, local checks are fine without asking: formatters, type checks on a single file, reading a log
- When no interactive channel is available, never block waiting for approval — name the check you want run and why, and leave it for whoever can approve it
- Report what was left unverified rather than verifying it
- Be specific about what a given check would and would not have caught
- When handing work back, state the verification state plainly instead of resolving it unilaterally
- Never claim a check passed unless it was actually run — cite the command and its real output
