# hardware/ — device and driver enablement (outside the stack)

**Not a layer.** Hardware answers _"what physical machine is this?"_, not _"how
much abstraction is this?"_, so it has no ordering relationship to the
`profile → capability → app → base` stack.

**Goes here:** driver/device enablement — `nvidia`, `audio`, `zsa`.

**Dependencies:** reachable from any layer and from hosts. In practice these are
included **only by hosts, directly** (like `nvidia`), never pulled in by a
capability or profile.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
