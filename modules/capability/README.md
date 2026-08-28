# capability/ — groupings that make something usable

The **second** layer of the stack. A capability composes one or more apps (and
platform settings) into something you can actually use.

**Test:** _"What can this machine do?"_ — `programming`, `terminal-emulator`,
`hyprland`, `ai`, `cli`, `backup`, …

**Goes here:** aspects that group apps/platform into a usable feature. A capability
composes apps rather than nesting them — e.g. `terminal-emulator.nix` does
`includes = [ <aegix/kitty> ]`, and `app/kitty.nix` stands on its own.

**Dependencies:** may include `app/` and `platform/` (one layer down) and other
`capability/` aspects. It must **not** point upward to `profile/`.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
