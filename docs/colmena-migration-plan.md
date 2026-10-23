# Colmena Migration Plan

Replace per-host `just deploy <host>` with a single fleet-wide deploy, without
maintaining a list of hosts anywhere but the host definitions themselves.

Phase 1 done. Written after a day of rolling a change across four machines one
`nixos-rebuild` at a time.

## Why

`just deploy <host>` works, but the fleet has outgrown it:

- **Four invocations per change**, each waiting on the last, each prompting for
  a sudo password.
- **A build error surfaces mid-rollout.** `fix(hosts/sentinel): caddy build
fails with stale plugin source hash` was found by deploying, after other
  hosts had already switched.
- **No rollback.** A deploy that leaves a host unreachable needs a console.
  This happened twice in one day — once on a fail2ban lockout, once on a
  `dbus -> broker` switch that had to become `nixos-rebuild boot` plus a reboot.
- **A hand-written host list is a second source of truth.** The flake already
  knows which hosts exist; anything that repeats that will drift.

## Why colmena over the alternatives

| Option                      | Verdict                                                                                                    |
| --------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Justfile loop over a list   | Rejected. Duplicates the host list and encodes ordering imperatively.                                      |
| Flake output + generic loop | Workable, no new dependency, but re-implements parallelism, failure handling and rollback by hand.         |
| **colmena**                 | Node set derived from the config; `deployment.targetHost` lives in the host definition; tags for grouping. |
| deploy-rs                   | Also good; its magic rollback is the strongest single feature. Heavier integration and a less natural fit. |

Colmena is `0.4.0` in the pinned nixpkgs. deploy-rs is also available, so
switching later is not foreclosed.

## Design

### Where node config lives

In the host aspect, beside everything else about that host — never in a central
list:

```nix
# modules/hosts/sentinel/default.nix
nixos = {
  aegix.deploy = {
    targetHost = "sentinel.lan";
    tags = [ "server" ];
  };
};
```

Adding a host makes it deployable; removing it removes it. Nothing enumerates
hosts anywhere else.

The options are `aegix.deploy.*` rather than colmena's own `deployment.*`.
Importing `colmena.nixosModules.deploymentOptions` into `den.default.nixos` was
the obvious way to make `deployment.targetHost` writable in a host aspect, and it
does not work: colmena's `eval.nix` unconditionally prepends its own
`deploymentOptions` to every node, the module system keys bare lambdas by
position rather than by value, and the two copies do not dedupe —

```
error: The option `deployment.targetHost' in `<unknown-file>' is already declared in `<unknown-file>'.
```

So `modules/platform/deploy.nix` declares the options in this repo's own
namespace, and `modules/flake/colmena.nix` maps them onto `deployment` in one
place, inside colmena's evaluation. The data stays visible in
`nixosConfigurations`, and nothing outside the hive depends on colmena.

### Which hosts are targets

Only machines that are deployed **to**. Workstations use `just switch` locally
and must not appear as nodes; `vm` is a test target; `specula` is aarch64 and
cannot be built on the laptop without emulation or a remote builder.

Rather than a list, gate on the presence of `aegix.deploy.targetHost` — a host
without one is not a node. That keeps the rule in one place and makes the
default safe.

As built, the nodes are `aegis`, `sentinel`, `torrens`, `theatrum`, `k8s-1`,
`k8s-2`, `k8s-3` and `buttars-desktop`. The desktop is in despite being a
workstation: it already runs sshd with a root key for exactly this. `specula`,
`buttars-laptop`, `wgu-wsl` and `vm` are out.

### Wiring it to den

den generates `nixosConfigurations`; colmena needs a hive. `modules/flake/colmena.nix`
builds one from the same aspects, so a node is not a second description of a
host.

**Colmena insists on evaluating.** `src/nix/hive/eval.nix` runs its own
`nixos/lib/eval-config.nix` per node and there is no seam for handing it a
finished `nixosConfiguration`. That turned out not to matter: den leaves each
host's complete module list at `nixosConfigurations.<host>._module.args.modules`,
and re-evaluating that list under colmena produces **bit-identical** system
derivations. `checks.colmena-matches-hosts` asserts it on every `nix flake check`.

Two details were needed to get there:

- **The version label.** Colmena's `evalConfig` takes `lib` from the nixpkgs
  _tree_, not from the nixpkgs _flake_, so `lib/flake-version-info.nix` is
  missing and every node builds as `26.11pre-git` instead of
  `26.11.20261008.8edc0c7`. Different toplevel, different `/etc/os-release`.
  The hive pins `system.nixos.versionSuffix` and `.revision` from
  `inputs.nixpkgs.lib.trivial` to close the gap.
- **nixpkgs config survives.** Colmena merges `meta.nixpkgs`'s overlays and
  config with `lib.mkBefore` rather than setting `nixpkgs.pkgs`, so this repo's
  `allowUnfree` and `self.overlays.*` are untouched. Had it set `nixpkgs.pkgs`,
  nixpkgs' `opt.pkgs.isDefined -> cfg.config == {}` assertion would have rejected
  the whole fleet.

The binary comes from the pinned nixpkgs (`colmena` in the devshell, 0.5.0),
matching the `__schema = "v0.5"` the hive emits. The `colmena` flake input is
only ever used for `lib.makeHive`, which is pure Nix — nothing is built from it.

## What must keep working

Anything already learned the hard way, which a migration could quietly undo:

- **`--use-substitutes`.** Pushing a full 8 GiB closure over ssh instead of
  letting the target fetch from cache. Nothing to do: colmena substitutes on the
  destination by default, and `--no-substitutes` turns it off. There is no
  `deployment.substituteOnDestination` option — that guess was wrong.
  `deployment.buildOnTarget` remains available where a host can build for itself.
- **Trusted users.** Deploys push locally-built, unsigned paths, and only a
  trusted user may add those. Derived from the host in `modules/defaults.nix`;
  colmena's `targetUser` must match that account. Every node deploys as `root`,
  which is trusted unconditionally, so the derivation is not load-bearing here.
- **`boot` instead of `switch`.** `colmena apply boot` exists; it is needed for
  changes systemd refuses to switch into, like the dbus implementation change.
- **Passwordless sudo.** Resolved since this was written: `modules/profile/server.nix`
  sets `wheelNeedsPassword = false` and enrolls a root key fleet-wide, and every
  node uses the default `targetUser = "root"`. No prompts.
- **`k8s-1/2/3` are absent from `.sops.yaml`** despite `<aegix/server>` wanting
  `buttars-password` and `k3s-token`. Pre-existing, unrelated to colmena, and the
  most likely surprise when those three are first applied.

## Phases

- [x] **1 — Establish the hive.** `colmena build` produces derivations identical
      to `nixos-rebuild --flake` for all eight nodes, asserted by
      `checks.colmena-matches-hosts`. Nothing deployed.
- [ ] **2 — One host.** `colmena apply --on aegis` — least critical machine, and
      the one that already needed a console this week.
- [ ] **3 — The fleet.** Tags for `server`, and `colmena apply --on @server`.
      Keep `just deploy` working throughout. `@server` is the four real servers
      only; `k8s-1/2/3` are tagged `k8s` because they cannot build until
      `k3s-token` exists, and colmena builds every selected node before
      deploying any of them — one unbuildable node would block the whole run.
- [ ] **4 — Retire the old path** only once a full rollout has succeeded twice.

## Open questions

- [x] Does `makeHive` take evaluated `nixosConfigurations`, or does it need to
      evaluate the modules itself? It evaluates them itself, from
      `_module.args.modules`, bit-identically. See "Wiring it to den".
- [x] Root key on every host, or accept a sudo prompt per host? Already settled
      by `modules/profile/server.nix` — root key and passwordless sudo fleet-wide.
- [ ] Parallelism: is a simultaneous rollout wanted at all? truenas serves NFS
      to three hosts, so rebooting them together is a real hazard — though that
      is a reboot concern rather than a deploy one.
- [ ] Does colmena's health-check story add anything over gatus, or duplicate it?

## Not in scope

Ordering between hosts. The only genuine dependency in the fleet is truenas,
which is not a NixOS host and therefore not a colmena node. Among the four
servers there is no deploy-time ordering worth encoding.
