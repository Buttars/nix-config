# profile/ — named bundles a machine opts into

The **top** of the four-layer aspect stack (`profile → capability → app → platform`).
A profile is a role a machine plays, assembled from capabilities.

**Test:** _"What role does this machine play?"_ — `workstation`, `laptop`,
`desktop`, `server`.

**Goes here:** aspects that bundle capabilities into a machine role. One aspect
per file: `profile/<name>.nix` declaring `aegix.<name>`.

**Dependencies:** may include `capability/` (one layer down) and other
`profile/` aspects. It must **not** reach directly into `app/` or `platform/` —
that skips a layer and the layer check will reject it.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
