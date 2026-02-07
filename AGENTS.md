# AGENTS.md

Purpose

This repository uses a dendritic, aspect-oriented Nix architecture implemented with the `den` library.

Goals

- Explicit composition over implicit defaults
- Clear separation of concerns (host vs user vs capability)
- Predictable reasoning about why something is enabled
- Easy multi-user and multi-host scaling

Core concepts

- Aspects are the unit of composition: a small module fragment that implements a single capability.
- Files are organizational; aspects (and where they are included) define behavior.
- Composition is explicit: include aspects rather than toggling flags across many files.

High-level structure

- Aspects live under `modules/` and are included from flake outputs, host files, or home-manager fragments.
- The top-level flake and `modules/default.nix` wire `den` and other composition helpers.

Dendritic pattern & `den`

- The dendritic pattern models configuration as a tree of small composable fragments (aspects).
- `den` provides helpers for defining users, home-manager fragments, and composing aspects.
- Prefer adding/reusing aspects: to change behavior for a host, include or override an aspect rather than mutating it in-place.
- Typical aspect conventions:

  - Keep aspects small and focused.
  - Document where an aspect is included (top-of-file comment).
  - Validate required inputs with `assert` and clear messages.

How agents should operate

- Default to non-interactive, deterministic commands (`just`, `nix`, `home-manager`).
- Do not modify files outside the requested scope without explicit permission.
- Preserve commit history; do not amend pushed commits unless requested.
- Run `just check` (or `nix flake check . --impure`) before proposing changes.

Build / lint / test (quick reference)

- List just tasks: `just --list`
- Flake check: `just check` or `nix flake check . --impure`
- Build: `nix build .`
- Enter dev shell: `nix develop`
- Deploy (NixOS): `just deploy` or `nixos-rebuild switch --flake . --use-remote-sudo`

Running a single test

This repo is mainly Nix config; language projects inside the tree will provide their own runners. General pattern:

1. Enter the dev shell for the project: `nix develop` (or use a specific devShell target)
2. Run the language test runner with the test filter. Examples:

  - Python: `pytest tests/test_file.py::TestClass::test_name`
  - Go: `go test ./path/to/pkg -run TestName`
  - Rust: `cargo test --test test_name -- --nocapture`
  - Node: `npm test -- tests/file.test.js -t "test name"`

Formatting & linting

- Nix: `nixpkgs-fmt`
- Lua: `stylua` (config at `dotfiles/.config/nvim/stylua.toml`)
- Shell: `shfmt` + `shellcheck`; Fish: `fish_indent`
- Suggested commands:

  ```sh
  nix run nixpkgs#nixpkgs-fmt -- ./**/*.nix
  nix run nixpkgs#stylua -- dotfiles/.config/nvim/**/*.lua
  nix run nixpkgs#shfmt -- -w scripts/**/*.sh
  nix run nixpkgs#shellcheck -- scripts/**/*.sh
  just check
  ```

Code style & conventions

- Philosophy: composition, explicitness, small diffs.

- Nix-specific
  - Small, focused modules. Use `let` for computed values. Use `builtins` and pinned inputs.
  - Prefer `kebab-case` for file/aspect names; follow existing attr naming (e.g. `stateVersion`) for attributes.
  - Document aspect inclusion points at the top of the file.

- Imports & composition
  - Use `den`/`flake-parts` helpers to include aspects.
  - Avoid copy-pasting large blocks; create a new aspect instead.

- Naming
  - Files/directories: `kebab-case` (e.g., `hosts/nixos/buttars-laptop`).
  - Nix attributes: follow project style (commonly `camelCase` for attributes).

- Types & typing
  - Nix: document expected attribute shapes via comments and assert required inputs.
  - Other languages: prefer explicit types (TypeScript, Go, Rust, Python type hints).

- Error handling
  - Fail early and loudly. Use `assert` in Nix with helpful messages.
  - Shell scripts: `set -euo pipefail` unless there is documented reason not to.

Agent operational rules (must-follow)

1. Read `AGENTS.md` and `just --list` before making changes.
2. Do not change files outside the requested scope without permission.
3. Do not update `flake.lock` unless user requested input updates.
4. If modifying `hosts/*`, warn about deployment impact and include exact `just deploy` steps.
5. Run formatters/linters before committing.

Cursor / Copilot rules

- Cursor rules: none detected in `.cursor/rules/` or `.cursorrules`.
- Copilot instructions: none detected in `.github/copilot-instructions.md`.

If these appear later, add a short summary here and commit the rules directory.

Notes

- Keep PRs small and focused. For large refactors include a rollback plan and testing steps in the PR body.
- When creating new aspects, add a top-of-file usage comment and tests where reasonable.
