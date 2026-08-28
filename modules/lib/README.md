# lib/ — functions, not aspects (outside the stack)

**Not a layer.** These are reusable functions that are _called_, not
_included_, so they don't participate in layering at all.

**Goes here:** parametric helpers — e.g. `aegix.disks.provides.btrfs`, invoked
as `<aegix/disks/btrfs> { device = ...; }` from a host's disk config.

**Does not go here:** anything you add via `includes = [ ... ]` — that's an
aspect and belongs in one of the stack layers.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
