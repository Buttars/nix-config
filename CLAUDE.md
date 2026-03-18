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

`flake.nix` passes `./modules` to `import-tree`, which auto-imports every `.nix` file in the directory. Files prefixed with `_` (e.g., `_disko.nix`) are **skipped** by import-tree and must be imported manually.

### Den fundamentals

**`modules/den.nix`** is the core setup file. It:
- Injects `__findFile` into all modules, enabling `<den/...>` and `<aegis/...>` angle-bracket path resolution
- Registers `aegis` as a namespace (maps `<aegis/foo>` → `modules/features/foo.nix`)
- Sets global NixOS defaults: home-manager, disko, stylix modules; locale, timezone, state version

**`modules/default.nix`** sets cross-cutting defaults:
- `den.schema.user.classes = ["homeManager"]` — all users get home-manager by default
- `home-manager.useGlobalPkgs/useUserPackages`
- Default includes for all hosts: `<den/define-user>`, `<aegis/devenv>`, hostname assignment

### Defining a host

```nix
# modules/hosts/<hostname>/default.nix
{ __findFile, inputs, ... }:
{
  den.hosts.x86_64-linux.<hostname> = {
    users.<username>.classes = [ "home-manager" ];
  };
  den.aspects.<hostname> = {
    includes = [ <den/define-user> <aegis/networking> <aegis/audio> ];
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
    includes = [ <den/primary-user> (den._.user-shell "fish") <aegis/cli> ];
    homeManager = { pkgs, ... }: { ... };
  };
  # Wire user to a host:
  den.hosts.x86_64-linux.<hostname>.users.<username>.aspect = "<username>";
}
```

### Aspect library (`modules/features/`)

Each file exports `aegis.<name>` with `nixos` and/or `homeManager` keys. The `<aegis/name>` syntax resolves to the corresponding file. Including an aspect in both a host and a user is intentional — the host include applies the `nixos` class config, the user include applies the `homeManager` class config.

### Disk layout (`modules/disks.nix`)

Provides `aegis.disks.provides.btrfs` — a parametric function for btrfs+LUKS layouts. Each host that uses disko defines its own `_disko.nix` with `disko.devices`.

### Theming

Stylix is imported globally via `den.default.nixos.imports`. Each host's `_stylix.nix` sets `stylix.base16Scheme` and `stylix.image`.

## Key Constraints

- **`__findFile` must be in every module's arg pattern** that uses `<den/...>` or `<aegis/...>` syntax. The formatter (`deadnix`) is configured with `--no-lambda-pattern-names` to preserve it — do not remove it manually either.
- **`flake.nix` key ordering**: flake-file requires `url` before `inputs.*` within each input attrset. Run `nix run .#write-flake` to fix ordering.
- **Unfree packages**: Set `nixpkgs.config.allowUnfree = true` in the host's nixos config (e.g., for nvidia).
- **Commit style**: `type(scope): description` — e.g., `feat(host/buttars-laptop): ...`, `fix(features/fish): ...`, `refactor(modules): ...`
