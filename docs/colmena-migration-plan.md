# Colmena Migration Plan

Replace per-host `just deploy <host>` with a single fleet-wide deploy, without
maintaining a list of hosts anywhere but the host definitions themselves.

Not started. Written after a day of rolling a change across four machines one
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
  deployment = {
    targetHost = "sentinel.lan";
    targetUser = "sentinel";
    tags = [ "server" "nfs-client" ];
  };
};
```

Adding a host makes it deployable; removing it removes it. Nothing enumerates
hosts anywhere else.

### Which hosts are targets

Only machines that are deployed **to**. Workstations use `just switch` locally
and must not appear as nodes; `vm` is a test target; `specula` is aarch64 and
cannot be built on the laptop without emulation or a remote builder.

Rather than a list, gate on the presence of `deployment.targetHost` — a host
without one is not a node. That keeps the rule in one place and makes the
default safe.

### Wiring it to den

den generates `nixosConfigurations`; colmena needs a hive. The clean path is a
flake output built from the same aspects, so a node is not a second description
of a host:

```nix
# modules/flake/colmena.nix
flake.colmenaHive = inputs.colmena.lib.makeHive {
  meta.nixpkgs = ...;
  # nodes derived from nixosConfigurations that declare deployment.targetHost
};
```

The open question is how cleanly `makeHive` accepts already-evaluated
configurations versus wanting to evaluate them itself — that is the first thing
to establish, because the answer shapes everything else. If it insists on
evaluating, the hive has to be built from the same den aspect list rather than
from `nixosConfigurations`, and the work is larger than it looks.

## What must keep working

Anything already learned the hard way, which a migration could quietly undo:

- **`--use-substitutes`.** Pushing a full 8 GiB closure over ssh instead of
  letting the target fetch from cache. Colmena's equivalent is
  `deployment.substituteOnDestination = true`, or `buildOnTarget` where the
  host can build for itself.
- **Trusted users.** Deploys push locally-built, unsigned paths, and only a
  trusted user may add those. Derived from the host in `modules/defaults.nix`;
  colmena's `targetUser` must match that account.
- **`boot` instead of `switch`.** `colmena apply boot` exists; it is needed for
  changes systemd refuses to switch into, like the dbus implementation change.
- **Passwordless sudo is still absent.** `wheelNeedsPassword = true`, so
  colmena will prompt per host unless `targetUser = "root"`, which needs a root
  key on every host — today only some have one, added by hand at install.

## Phases

- [ ] **1 — Establish the hive.** Get `colmena build` producing the same
      derivations as `nixos-rebuild --flake` for one host. No deploying.
- [ ] **2 — One host.** `colmena apply --on aegis` — least critical machine, and
      the one that already needed a console this week.
- [ ] **3 — The fleet.** Tags for `server`, and `colmena apply --on @server`.
      Keep `just deploy` working throughout.
- [ ] **4 — Retire the old path** only once a full rollout has succeeded twice.

## Open questions

- [ ] Does `makeHive` take evaluated `nixosConfigurations`, or does it need to
      evaluate the modules itself? Everything else depends on this.
- [ ] Root key on every host, or accept a sudo prompt per host? A declarative
      `users.users.root.openssh.authorizedKeys.keys` would make this uniform —
      today theatrum has a root key and aegis did not, purely by accident of
      installation.
- [ ] Parallelism: is a simultaneous rollout wanted at all? truenas serves NFS
      to three hosts, so rebooting them together is a real hazard — though that
      is a reboot concern rather than a deploy one.
- [ ] Does colmena's health-check story add anything over gatus, or duplicate it?

## Not in scope

Ordering between hosts. The only genuine dependency in the fleet is truenas,
which is not a NixOS host and therefore not a colmena node. Among the four
servers there is no deploy-time ordering worth encoding.
