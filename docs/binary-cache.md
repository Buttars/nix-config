# Binary Cache — Runbook

A shared LAN cache so a package built on one machine is never built again on
another. `attic` on `sentinel`; every NixOS host pulls from it, and the six that
can decrypt sops push to it.

## Why attic

A real cache with its own storage, not a shared `/nix/store`.

| Option                                    | Verdict                                                                                     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------- |
| **attic on sentinel**                     | Own chunk store, own retention, HTTP push with a token.                                     |
| nix-serve / harmonia on sentinel          | Rejected: store sharing, and the GC below kills it.                                         |
| harmonia on buttars-desktop               | Rejected: VLAN 40 cannot reach VLAN 20, so no server ever benefits.                         |
| `ssh-ng://buttars-desktop` as substituter | Same VLAN problem. The remote builder already covers the laptop, which is all it could fix. |
| post-build-hook + `nix copy --to ssh://`  | Same GC problem, plus a root ssh key on every pusher.                                       |
| Cachix                                    | Hosted and paid at this volume, and closures leave the house.                               |

### The GC argument is decisive, not a preference

`nix-serve` and `harmonia` store nothing — they re-serve the host's own
`/nix/store`, so pushing means `nix copy --to ssh://sentinel`, which lands
paths with **no GC root**.

`--delete-older-than 14d` in `<aegix/nix-gc>` only bounds how many _profile
generations_ survive. Collection still removes every path not reachable from a
root, whatever its age — so a pushed path disappears at the next weekly run,
not after fourteen days. Making that work needs `nix-store --add-root` per path
plus a retention scheme of one's own, which is attic reimplemented badly.

Attic keeps chunks in `/var/lib/atticd/storage`, outside the nix store, and
enforces `default-retention-period` itself. The two collectors never meet.

### What attic costs

Maintenance is thin: no tagged release has ever been cut, `main` has not moved
since 2026-07-06, and nixpkgs tracks an unstable git revision — which is what
`0-unstable-2026-07-06` means. Acceptable here because the cache holds only
things that can be rebuilt: if it rots, the service goes away and nothing is
lost but the cache itself. Worth re-checking before anything load-bearing
depends on it.

## Shape

| Piece                                 | Where                                                |
| ------------------------------------- | ---------------------------------------------------- |
| `services.atticd`, port 8081          | `modules/hosts/sentinel/attic.nix`                   |
| substituter + `attic watch-store`     | `modules/app/attic.nix` (`<aegix/attic>`)            |
| included on every host                | `den.schema.host.includes` in `modules/defaults.nix` |
| `buttars-desktop` as a remote builder | `modules/hosts/buttars-laptop/builders.nix`          |

Pushers are `aegis`, `sentinel`, `torrens`, `theatrum`, `buttars-desktop` and
`buttars-laptop` — each sets `aegix.attic.push = true`.

Not pushing, and why:

- `k8s-1/2/3` — their age keys are missing from `.sops.yaml`, so they cannot
  decrypt the client token. They still pull.
- `specula` — 512 MB aarch64 Pi, built as an SD image rather than building.
- `wgu-wsl` — work machine, not on the LAN.

## Bootstrap

The token cannot exist before the server does, so this runs in two deploys.

### 1. Server secret

No server needed for this one:

```sh
openssl genrsa -traditional 4096 | base64 -w0
sops modules/app/sops/secrets.yaml
```

Add two keys. `attic-server-env` is an EnvironmentFile:

```
attic-server-env: |
  ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=<the base64 blob>
```

and `attic-client-config` as a placeholder, so the five other pushers can
activate before a token exists:

```
attic-client-config: |
  default-server = "lan"

  [servers.lan]
  endpoint = "http://sentinel.lan:8081/"
  token = ""
```

### 2. Deploy sentinel

```sh
just deploy sentinel
ssh sentinel systemctl status atticd
```

### 3. Mint a token and create the cache

On sentinel:

```sh
atticd-atticadm make-token \
  --sub buttars --validity 10y \
  --pull lan --push lan --delete lan \
  --create-cache lan --configure-cache lan --configure-cache-retention lan
```

`--configure-cache-retention` is not optional despite `--public` having nothing
to do with retention: `attic cache configure` sends the whole cache config, and
the server checks the retention permission whenever those fields are present.
Without it `--public` fails with a bare `AccessError`.

Then from any machine, using that token:

```sh
attic login lan http://sentinel.lan:8081/ <token>
attic cache create lan
attic cache configure lan --public   # pulling needs no token; pushing still does
attic cache info lan                 # prints the public signing key
```

### 4. Wire the key and the token back in

- Put the real token into `attic-client-config` in
  `modules/app/sops/secrets.yaml`.
- Put the public key from `attic cache info lan` into the `publicKey` option's
  default in `modules/app/attic.nix`. Until it is set, no host configures the
  substituter at all — nix rejects paths it cannot verify, so pointing at the
  cache without the key would only hide the mistake.

### 5. Deploy the fleet

```sh
just deploy aegis && just deploy torrens && just deploy theatrum
sudo nixos-rebuild switch --flake .#buttars-laptop
```

### 6. Seed it from what is already built

The hook only fires on future builds, so everything `buttars-desktop` has
already built is invisible to the cache. Seed it once, from the desktop, with
the closures the fleet actually needs:

```sh
nix eval --impure --raw --expr '
  let f = builtins.getFlake "/home/buttars/Projects/nix-config"; in
  builtins.concatStringsSep "\n"
    (map (n: f.nixosConfigurations.${n}.config.system.build.toplevel.outPath)
      [ "aegis" "sentinel" "torrens" "theatrum" ])' \
| xargs attic push --jobs 8 lan
```

Only works for closures the desktop has actually realised — it builds anything
missing rather than failing, so run it where the builds already exist.

**Do not push the whole store.** `buttars-desktop` holds 53k paths across
115 GB; `attic push lan /nix/store/*/` expands to roughly 3 MB of argv and dies
on `ARG_MAX` before it starts. If a full sweep is ever wanted it has to go
through `xargs`:

```sh
ls -d /nix/store/*/ | grep -v '\.drv$' | xargs -n 500 attic push --jobs 8 lan
```

That is still hours of upstream-filter queries for little gain. Attic refuses
to store anything `cache.nixos.org` already has, so the fraction worth
uploading is small and the targeted form above captures nearly all of it.

## Checks

```sh
# the cache answers and nix recognises it
curl -s http://sentinel.lan:8081/lan/nix-cache-info

# the substituter is in effect
nix config show substituters

# uploads are happening
systemctl status attic-watch-store
journalctl -u attic-watch-store -f
```

## Remote builder

`buttars-laptop` offloads to `buttars-desktop` over `ssh-ng` as root, using the
buttars key placed at `/root/.ssh/id_ed25519` by sops. The desktop already
enrolls that public key for root. `builders-use-substitutes` is on, so the
desktop fetches dependencies itself instead of having them pushed through the
laptop's uplink. The desktop declares `aarch64-linux` too, via its binfmt
emulation.

Check it:

```sh
nix store ping --store ssh-ng://root@buttars-desktop.lan
nix build --impure .#nixosConfigurations.aegis.config.system.build.toplevel --print-build-logs
```

Off the LAN the builder is simply unreachable and nix builds locally. The same
applies to the cache: `connect-timeout = 5` and `fallback = true` are set
fleet-wide in `<aegix/attic>` so a roaming laptop does not stall on either.

## Follow-ups

- [ ] Add `k8s-1/2/3` age keys to `.sops.yaml` and flip their
      `aegix.attic.push`. They are already missing `buttars-password` and
      `k3s-token` for the same reason.
- [ ] Decide whether atticd's storage should move off sentinel's root disk onto
      the truenas NFS mount. The sqlite DB must stay local either way — sqlite
      over NFS locks badly.
- [ ] The cache is **public**: anything on the LAN can pull from it without a
      token. That is deliberate — it is what lets `k8s-1/2/3` benefit despite
      having no sops. Revisit if the LAN stops being trusted.
