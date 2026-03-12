Aspect Audit (Den-aware)
Date: 2026-03-11
Branch: dendritic-from-scratch

Purpose
- Inventory and audit of repository aspects (focus: `modules/` and
  `modules/features/`) using Den conventions. This document captures
  architectural observations, anti‑patterns to address, and prioritized
  remediation steps. Hyprland is intentionally excluded from issue flagging
  per the user's request; its behavior is preserved.

Den fundamentals (how I interpret aspects here)
- An aspect is an attrset that may contain per‑class modules (e.g. `nixos`,
  `homeManager`, `darwin`). The aspect file must evaluate to an attrset that
  defines `aegis.<aspect-name> = { ... }`.
- Angle-bracket lookups (e.g. `<aegis/audio>` or `<aegis/browser/brave>`) are
  resolved via Den's `__findFile`. When Nix evaluates `<aegis/...>` Den maps
  that to the file path which must export the aspect attrset.
- Composition is performed by `includes` (for DAG composition) and `provides`
  (to expose named sub‑aspects or implementations). `provides` may be
  parametric and accept `{ host, user, ... }` to conditionally apply config.

Audit scope & constraints
- Included: all files under `modules/` and `modules/features/`, except
  Hyprland-specific issues (per user instruction).
- I focus on Den conventions: owned configs, includes/provides, parametric
  behavior, and cross-class purity.

Top anti‑patterns observed (excluding Hyprland)
- Mixed system/user concerns without explicit ownership comments
  - Several files declare both `nixos` and `homeManager` fragments but
    lack a short header describing intended ownership/override knobs.
- Duplication of cross‑cutting capability declarations
  - Fonts and theming overlap: both aspects declare fonts; centralize.
- Vendor implementations not exposed via `provides`
  - `modules/features/browser.nix` and some others define product fragments
    inline rather than as `provides` (makes swapping implementations harder).
- Hardware logic not isolated as hardware aspects
  - NVIDIA and ZSA pieces are located among features rather than a
    `hardware/*` hierarchy with parametric `provides` to gate activation.
- “Junk-drawer” aspects
  - Aspects like `programming` bundle many unrelated tools; consider splitting
    by capability (editors, runtimes, devtools).
- Bindings/scripts referencing binaries not ensured present
  - Various scripts and binds reference programs without guaranteeing those
    binaries are in the aspect's `home.packages` (outside Hyprland too).
- Large assets and secrets
  - Some repositories include large binaries or TODO‑flagged secret files —
    treat assets in `dotfiles` and encrypt secrets with sops/git‑crypt.

Den‑aligned remediation (prioritized)
Immediate (low risk)
1. Add per‑aspect header comments to every aspect file: Category (capability,
   vendor, hardware, profile) and Exports (nixos, homeManager, darwin). This
   is a documentation-only change and makes ownership explicit.
2. Centralize fonts: designate `modules/features/fonts.nix` as source of
   truth and update `theming` to reference fonts (use `lib.mkDefault` where
   needed so changes are non‑breaking).
3. Detect and list large files and potential secrets (read‑only scan), then
   move assets to `dotfiles` or external storage as appropriate.

Short term (safe refactors)
4. Convert vendor fragments into `provides` entries (e.g., browsers, password
   manager backends). Provide compatibility shims so `<aegis/...>` lookups keep
   resolving during migration.
5. Create `modules/features/hardware/*` and move hardware implementations
   (nvidia, zsa). Expose them as parametric `provides` that check host attrs.

Medium term
6. Split large aspects (e.g., `programming`) into finer capability aspects.
7. Add guards or ensure packages for binaries referenced by scripts/bindings.

Long term
8. Add CI: den/Nix eval checks for representative hosts, and periodic audits
   (TODOs, secrets, large files).

Practical checks to run (I can run these if you want)
- TODOs: rg -n "TODO|FIXME" modules
- Large assets: git ls-files | rg -nE "\.(jpg|png|gif|mp4)$"
- Potential secrets: rg -n --hidden --no-ignore-vcs "password|secret|token|key|passwd" modules || true
- Aspect map: parse files referenced by `__findFile` (angle brackets) and list exported classes.

Notes about `__findFile` and safe refactor constraints
- Because `__findFile` resolves `<aegis/...>` to a file that must export the
  corresponding aspect attrset, any file moves must preserve compatibility:
  either keep a shim file at the old path that re‑exports the new location,
  or update `__findFile` mapping. Plan refactors accordingly.

Where this file is saved
- `docs/aspect-audit.md` (this file) — committed to the branch for reference.

Next actionable options (pick one)
1. I will run the read‑only scans and produce exact lists (TODOs, binaries,
   secrets candidates, aspect exports). (Recommended first.)
2. I prepare the small, non‑destructive PRs for Immediate items (headers,
   fonts centralization, docs). I will not apply them until you approve.
3. I implement the Immediate items directly on this branch now (I can do
   that if you want me to continue making edits).

Which of the three do you want me to do next?
