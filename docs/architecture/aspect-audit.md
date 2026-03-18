Aspect Audit (Den‑aligned)
Date: 2026-03-11 (updated 2026-03-12)
Branch: dendritic-from-scratch

Purpose

- Re‑audit the repository with strict adherence to Den's aspect model and the
  `__findFile` angle‑bracket resolution rules. Remove recommendations or
  observations that do not align with how Den expects aspects to be authored
  and consumed.

Scope & constraints

- Scope: `modules/` and `modules/features/` (inventory and recommendations).
- Hyprland: excluded from criticism per user instruction — inventory only.
- All suggestions follow Den primitives: aspects are attrsets exporting
  per‑class modules (nixos, homeManager, darwin, etc.). Angle‑bracket
  lookups (e.g. `<aegis/audio>`) are resolved via `__findFile` and therefore
  every path must continue to resolve to a file exporting the expected aspect
  attrset.

Den model recap (concise)

- Aspect = attrset that may contain per‑class modules:

  aegis.foo = {
  nixos = { pkgs, ... }: { ... };
  homeManager = { pkgs, ... }: { ... };
  darwin = { ... };
  };

- `__findFile` resolves `<aegis/foo>` to the file that must export `aegis.foo`.
- `__findFile` maps `/` to `.provides.` so `<aegis/foo/bar>` resolves to
  `aegis.foo.provides.bar` semantics.
- Use `includes` to compose aspects and `provides` to expose selectable
  implementations. Parametric `provides` can accept `{ host, user, ... }`.

Inventory (aspects discovered)

- For each aspect below we list: aspect name → file path → exported classes.
- Note: this inventory is produced by scanning `modules/` and `modules/features/`.

1. aegis.audio
   - file: modules/features/audio.nix
   - exports: nixos

2. aegis.browser
   - file: modules/features/browser.nix
   - exports: homeManager (vendor sub-entries for google-chrome and brave)

3. aegis.cli
   - file: modules/features/cli.nix
   - exports: homeManager (and sub-aspects `_.tui`, `_.aws`, `_.git` also expose homeManager)

4. aegis.discord
   - file: modules/features/discord.nix
   - exports: homeManager

5. aegis.element-desktop
   - file: modules/features/element-desktop.nix
   - exports: homeManager

6. aegis.fish
   - file: modules/features/fish.nix
   - exports: (top-level) programs + homeManager fragment

7. aegis.fonts
   - file: modules/features/fonts.nix
   - exports: nixos

8. aegis.gaming
   - file: modules/features/gaming.nix
   - exports: nixos

9. aegis.hyprland (inventory only)
   - files: modules/hyprland.nix (system), modules/features/hyprland/default.nix (user)
   - exports: nixos, homeManager

10. aegis.locale
    - file: modules/features/locale.nix
    - exports: nixos

11. aegis.neovim
    - file: modules/features/neovim.nix
    - exports: homeManager

12. aegis.nfs-utils
    - file: modules/features/nfs-utils.nix
    - exports: nixos

13. aegis.nix-ls
    - file: modules/features/nix-ls.nix
    - exports: nixos

14. aegis.nvidia
    - file: modules/features/nvidia.nix
    - exports: nixos

15. aegis.password-manager
    - file: modules/features/password-manager.nix
    - exports: homeManager (implements sub-entries for keepassxc and bitwarden)

16. aegis.programming
    - file: modules/features/programming.nix
    - exports: homeManager

17. aegis.taskwarrior
    - file: modules/features/taskwarrior.nix
    - exports: homeManager

18. aegis.terminal-emulator
    - file: modules/features/terminal-emulator.nix
    - exports: homeManager

19. aegis.theming
    - file: modules/features/theming.nix
    - exports: homeManager

20. aegis.virtualization
    - file: modules/features/virtualization.nix
    - exports: provides for docker / libvirtd; contains nixos fragments

21. aegis.xdg
    - file: modules/features/xdg.nix
    - exports: homeManager

22. aegis.zsa
    - file: modules/features/zsa.nix
    - exports: nixos

23. other aspects and host aspects
    - modules/devenv.nix → aegis.devenv (homeManager)
    - modules/disks.nix → aegis.disks.provides.btrfs (provides)
    - modules/sops/default.nix → aegis.secrets (homeManager + nixos)
    - modules/networking.nix → aegis.networking (nixos)
    - modules/power-management.nix → aegis.power-management (nixos)
    - host aspects under modules/hosts/\* (den.aspects.<host> entries)

Aligned observations (only Den‑relevant issues)

- Per‑class ownership must be explicit: many aspect files already follow the
  pattern (e.g., declare `nixos = ...` or `homeManager = ...`). Maintain the
  per‑class separation — do not collapse class fragments into a single mixed
  module; Den evaluates each class module in its context.
- Use `provides` for vendor implementations: where an aspect exposes multiple
  product implementations (browser, password-manager), prefer `provides` so
  callers can select a provider with `<aegis/aspect/provider>` and includes.
- Parametric provides for hardware: hardware providers (nvidia, zsa) should
  be authored as parametric `provides` that accept `{ host, ... }` and apply
  only when the host attributes match (e.g., `host.gpu == "nvidia"`). This
  reduces accidental hardware enablement across hosts.
- Keep `__findFile` compatibility in mind when moving files: any file that
  used to be addressable by `<aegis/name>` must continue to resolve (either
  keep a shim at the original path or update the mapping used by Den's
  `__findFile`).
- Centralize cross‑cutting capabilities: `fonts.nix` is a sensible source of
  truth for font packages; other aspects (theming) should reference the
  fonts aspect (or use `lib.mkDefault`) rather than redeclare packages.
- Avoid embedding host specifics without a clear override path (use
  `lib.mkDefault` or parametric includes). Values like monitor geometry or
  device paths should be overridable by host configuration.
- Ensure aspects include or guard any binaries their scripts/keybinds rely on.
  Either ensure the binary is in the same aspect's `home.packages` or add a
  conditional registration based on package availability.

Removed or changed recommendations (den‑aligned)

- Removed suggestions that treated an aspect as a single module; aspects are
  now treated as attrsets with per‑class modules per Den's model.
- Removed advice that suggested moving aspects without accounting for
  `__findFile` compatibility. Any move must preserve angle‑bracket resolution
  via a shim or by updating Den's findFile mapping.
- Removed generic language about "capability-default vs profile-default" and
  replaced it with Den patterns: use `includes` and `provides` to expose
  capabilities and profile/bundle aspects explicitly; pick conventions and
  document them in `modules/features/README.md`.

Concrete, safe next steps (Den‑centric)

1. Add a one‑line header to each aspect file indicating: Category and Exports
   (nixos/homeManager/etc.). This is documentation only and aligns with Den.
2. Convert inline vendor fragments to `provides` where appropriate (browser,
   password-manager). Provide compatibility shims at the existing `<...>` file
   paths during migration.
3. Move hardware implementations to a `hardware/*` location and expose them
   via parametric `provides` (host gated). Keep shims if required by
   existing `<...>` consumers.
4. Centralize fonts (fonts.nix) and have theming reference fonts via `mkDefault`.
5. Add a short README in `modules/features/` explaining how to add aspects,
   how to select providers via `<aegis/aspect/provider>`, and how to keep
   overrides parametric.

Appendix — checklist for each aspect file

- Does the file evaluate to an attrset exporting `aegis.<name>`? (required)
- Which classes does it export (nixos/homeManager/darwin)? Are the
  per‑class modules pure and small?
- If multiple implementations exist, are they placed under `provides` so that
  callers can use `<aegis/<aspect>/<provider>>`?
- Does the file avoid hard‑coding host specifics (or expose overrides via
  `lib.mkDefault` or parametric includes)?
- Does the file ensure packages referenced by scripts/keybinds are present,
  or conditionally register those features?

End of audit
