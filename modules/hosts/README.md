# hosts/ — one directory per machine

**Entities, not part of the aspect stack.** Each `hosts/<hostname>/` declares
`den.hosts.*` / `den.aspects.<hostname>`, wires the machine's users, and pulls
in the layers and hardware it needs.

**Goes here:** per-machine config in `hosts/<hostname>/default.nix`, plus
host-owned data files:

- `_disko.nix` — disk layout, imported manually (`nixos.imports = [ ./_disko.nix ]`)
- `_stylix.nix` — per-host theme
- `hardware-configuration.nix` / `facter.json` — hardware description

A host may include **any** layer (`profile`/`capability`/`app`/`base`) plus the
siblings (`hardware/`, `lib/`).

**`_` prefix caveat:** import-tree skips any path containing `/_`, so `_`-files
are imported explicitly. `hardware-configuration.nix` is deliberately **not**
prefixed — it declares `den.aspects.<host>.nixos` and must stay auto-imported.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
