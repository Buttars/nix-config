# users/ — one directory per user

**Entities, not part of the aspect stack.** Each `users/<username>/` declares
`den.aspects.<username>` (the user's home-manager aspect) and can wire the user
onto hosts.

**Goes here:** per-user config in `users/<username>/default.nix` and split files
(`git.nix`, `home.nix`, …). Users get the `homeManager` class by default
(`den.schema.user.classes` in `modules/defaults.nix`).

A user aspect's `includes` pull in aspects from the stack (e.g. `<aegix/cli>`,
`(den._.user-shell "fish")`); the `homeManager` class config of each included
aspect is what applies to the user.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
