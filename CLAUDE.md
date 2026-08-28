# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

```bash
nix flake check --impure   # Validate all configurations
nix run .#fmt              # Format all files (nixfmt, deadnix, shfmt, prettier)
nix run .#vm               # Run the test VM
nix run .#write-flake      # Regenerate flake.nix after changing flake-file.inputs in modules
```

> `flake.nix` is auto-generated — never edit it directly. Use `nix run .#write-flake` after modifying `flake-file.inputs` declarations in any module.

## Architecture

This repo uses **Den** (`github:vic/den`), an aspect-driven NixOS configuration framework. The core pattern is:

```
Aspects (reusable feature units)
  → included by Hosts and Users
  → each aspect exports per-class modules: nixos, homeManager, darwin
```

### How modules are loaded

`flake.nix` passes `./modules` to `import-tree`, which auto-imports every `.nix` file in the directory. Any path containing `/_` (e.g. `_disko.nix`, `_hm-dotfiles.nix`) is **skipped** and must be imported manually.

> **Never `_`-prefix a file that declares `den.*` or `aegix.*`.** Those files are reached _only_ by auto-import, so prefixing one silently deletes it from the build. `modules/hosts/*/hardware-configuration.nix` declares `den.aspects.<host>.nixos` despite its name.

### Module layout

`modules/` is a four-layer stack plus two siblings. **Full reference: [docs/architecture/module-structure.md](docs/architecture/module-structure.md).**

```
modules/
├── den.nix defaults.nix ci-noboot.nix   den bootstrap (no other loose .nix here)
├── flake/        flake-parts outputs that are not aspects
├── profile/      workstation laptop desktop server
├── capability/   groupings that make something usable
├── app/          one program or service each
├── platform/         machine-level settings with no program behind them
├── hardware/     device and driver enablement   <- outside the stack
├── lib/          functions, not aspects         <- outside the stack
└── hosts/ users/ entities
```

Includes only ever step **down** one layer: `profile → capability → app → platform`. `hardware/` and `lib/` are reachable from anywhere; hosts are not part of the stack and may include any layer. `checks.module-layers` enforces this — run `nix flake check --impure`.

**Where does a new file go?** Declares `aegix.<name>` → `modules/<layer>/<name>.nix`, one aspect per file. Declares a host or user → `modules/hosts/` or `modules/users/`. A flake-parts output not tied to an entity → `modules/flake/`. A plain NixOS/HM module → prefix `_` and import it explicitly.

### Den fundamentals

**`modules/den.nix`** is the core setup file. It:

- Injects `__findFile` into all modules, enabling `<den/...>` and `<aegix/...>` angle-bracket resolution
- Registers `aegix` as a namespace. **`<aegix/foo>` is not a path** — it resolves to the attribute `config.den.ful.aegix.foo`. Nothing checks where the aspect was defined, so the file convention above is enforced by `checks.module-layers`, not by den.
- Sets global NixOS defaults: home-manager, disko, stylix modules; locale, timezone, state version

**`modules/defaults.nix`** sets cross-cutting defaults:

- `den.schema.user.classes = ["homeManager"]` — all users get home-manager by default
- `home-manager.useGlobalPkgs/useUserPackages`
- Default includes for all hosts: `<den/define-user>`, `<aegix/devenv>`, hostname assignment

### Defining a host

```nix
# modules/hosts/<hostname>/default.nix
{ __findFile, inputs, ... }:
{
  den.hosts.x86_64-linux.<hostname> = {
    users.<username>.classes = [ "home-manager" ];
  };
  den.aspects.<hostname> = {
    includes = [ <den/define-user> <aegix/networking> <aegix/audio> ];
    nixos = { pkgs, ... }: { ... };
    homeManager = { pkgs, ... }: { ... };
  };
}
```

Disk config goes in a separate `_disko.nix` (manually imported via `nixos.imports = [./_disko.nix]`). This avoids a duplicate-module evaluation bug that occurs when disko devices are defined in an auto-imported file.

### Defining a user

```nix
# modules/users/<username>/default.nix
{ __findFile, den, ... }:
{
  den.aspects.<username> = {
    includes = [ <den/primary-user> (den._.user-shell "fish") <aegix/cli> ];
    homeManager = { pkgs, ... }: { ... };
  };
  # Wire user to a host:
  den.hosts.x86_64-linux.<hostname>.users.<username>.aspect = "<username>";
}
```

### Aspect library

Each file exports `aegix.<name>` with `nixos` and/or `homeManager` keys, under whichever layer it belongs to. Including an aspect in both a host and a user is intentional — the host include applies the `nixos` class config, the user include applies the `homeManager` class config.

OS-specific logic (darwin vs linux) belongs in the aspect itself, not in host or user definitions. Use `pkgs.stdenv.isDarwin` / `pkgs.stdenv.isLinux` and `lib.mkIf` within the aspect to branch behavior per platform unless told otherwise.

A capability composes apps rather than nesting them: `capability/terminal-emulator.nix` does `includes = [ <aegix/kitty> ]`, and `app/kitty.nix` stands on its own. Reserve `_.<name>` sub-aspects for internal facets of a single aspect (`zsh._.vi-mode`, `tmux._.gitmux`).

### Disk layout (`modules/lib/disks.nix`)

Provides `aegix.disks.provides.btrfs` — a parametric function for btrfs+LUKS layouts. Each host that uses disko defines its own `_disko.nix` with `disko.devices`.

### Theming

Stylix is imported globally via `den.default.nixos.imports`. Each host's `_stylix.nix` sets `stylix.base16Scheme` and `stylix.image`.

## Key Constraints

- **`__findFile` must be in every module's arg pattern** that uses `<den/...>` or `<aegix/...>` syntax. The formatter (`deadnix`) is configured with `--no-lambda-pattern-names` to preserve it — do not remove it manually either.
- **`flake.nix` key ordering**: flake-file requires `url` before `inputs.*` within each input attrset. Run `nix run .#write-flake` to fix ordering.
- **Unfree packages**: Set `nixpkgs.config.allowUnfree = true` in the host's nixos config (e.g., for nvidia).

## Commit Guidelines

Follow **Conventional Commits** with imperative present tense:

**Format**: `type(scope): description`

**Types**:

- `fix`: Bug fixes — describe the bug, not the change
- `feat`: New features
- `style`: Code style changes (formatting, whitespace)
- `chore`: Maintenance tasks (dependencies, tooling)
- `docs`: Documentation changes
- `refactor`: Code refactoring without behavior changes
- `test`: Test additions or modifications
- `perf`: Performance improvements

**Examples**:

- `feat(host/buttars-laptop): add nvidia driver support`
- `fix(features/fish): shell initialization fails on first login`
- `refactor(modules): extract common disk configuration`
- `chore(flake): update lockfile`

**Commit bodies**: Prefer empty bodies unless there is relevant information (e.g., issue links, breaking changes, or non-obvious context).

**Special cases**:

- Flake lock updates: Always use `chore(flake): update lockfile`

**Fix commits**: Describe what wasn't working, not what you changed.

- ✅ `fix(darwin): home-manager configuration not applied to users`
- ❌ `fix(darwin): add home-manager module import`

**Atomic commits**: Each commit should contain exactly one logical change. Split unrelated changes into separate commits.
