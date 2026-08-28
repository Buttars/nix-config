# base/ — machine-level settings with no program behind them

The **bottom** of the stack. Cross-cutting system configuration that isn't a
program.

**Test:** _"Is this config with no program behind it?"_ — `locale`,
`networking`, `fonts`, `xdg`, `wayland`, `nix-ls`.

**Goes here:** plumbing/settings aspects, one aspect per file.

**Dependencies:** none — `base/` includes nothing. Every layer above may include
it.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
