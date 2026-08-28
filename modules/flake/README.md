# flake/ — flake-parts outputs that aren't aspects

Modules here contribute to the flake's **outputs** directly — `perSystem.*`,
`flake.*`, the formatter, `checks`, overlays, dev shells — rather than defining
an `aegix.<name>` aspect or a host/user entity.

**Goes here:** dendritic wiring, devenv/dev shell, treefmt formatter, overlays,
`checks`, and standalone `flake-file.inputs` for flake-parts modules.

**Does not go here:** anything declaring `aegix.*`, `den.hosts`, or
`den.aspects` (those are aspects/entities). An output that closes over one
specific entity lives with that entity instead — e.g. the VM's
`perSystem.packages.vm` is in `hosts/vm/`.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
