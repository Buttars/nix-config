# GitOps Deploy — Runbook

Push to `master`, and `torrens` and `theatrum` deploy themselves. Push-based,
not polling, and it does not depend on `buttars-desktop` being online.

## Shape

| Piece                        | Where                                        |
| ---------------------------- | -------------------------------------------- |
| self-hosted runner           | `modules/app/github-runner.nix`, on sentinel |
| workflow                     | `.github/workflows/deploy.yml`               |
| which hosts deploy           | `aegix.deploy.tags` containing `auto`        |
| deploy key enrolled for root | `modules/profile/server.nix`                 |

A push to `master` starts an ephemeral runner job on sentinel, which runs
`colmena apply --on @auto`. The `auto` tag is on `torrens` and `theatrum` only;
`aegis` and `sentinel` stay on manual `just deploy`.

Both automated hosts set `buildOnTarget = true`, so sentinel never builds — it
evaluates and orchestrates, and each target builds itself, pulling shared
dependencies from the attic cache. That keeps heavy builds off the host that
serves LAN DNS.

## Why the trigger is `push` only

`.github/workflows/deploy.yml` fires on `push` to `master` and nothing else.
This repository is **public**, and a self-hosted runner that could be reached by
`pull_request` from a fork would let anyone run code inside the LAN on a machine
holding root keys to the fleet. Only accounts with write access can push to
`master`, so a fork cannot reach the runner.

Keep `test.yml` (which does run on `pull_request`) on GitHub-hosted runners. If
a workflow ever needs `runs-on: self-hosted`, check its triggers first.

## Known risk

The runner lives on `sentinel`, which also serves LAN DNS and hosts the attic
cache. Running GitHub-dispatched code there is a deliberate, temporary choice —
the intent is to move it to a dedicated VM on `veritas`. Until then, a runner
compromise reaches the host the rest of the network depends on.

Moving it later is a two-line change: drop `<aegix/github-runner>` from
`sentinel`'s includes, add it to the new host, and re-register.

## Setup

### 1. The deploy key

A keypair was generated with the public half already committed at
`modules/users/buttars/keys/deploy.pub` and enrolled for `root` on every
`<aegix/server>` host. Put the private half into sops as `private_keys/deploy`:

```sh
sops modules/app/sops/secrets.yaml
```

Regenerate instead if you would rather hold the only copy:

```sh
ssh-keygen -t ed25519 -C nix-config-deploy -N "" -f /tmp/deploy_ed25519
cp /tmp/deploy_ed25519.pub modules/users/buttars/keys/deploy.pub
```

### 2. The runner token

A fine-grained PAT with **read and write access to repository self-hosted
runners** on `Buttars/nix-config`. A classic PAT with `repo` scope also works.
Store it as `github-runner-token`, with no trailing newline — the module is
explicit that a newline breaks registration:

```sh
sops modules/app/sops/secrets.yaml
```

A registration token from the "Add new self-hosted runner" page also works but
expires after an hour, so the next config change fails with an opaque 404. Use a
PAT.

### 3. Deploy sentinel

```sh
just deploy sentinel
ssh sentinel systemctl status github-runner-nix-config
```

The runner should appear under Settings → Actions → Runners with the label
`nix-config`.

### 4. Prove it

```sh
jj bookmark set master -r @
jj git push
```

Watch the run in the Actions tab.

## Checks

```sh
# runner is registered and listening
ssh sentinel systemctl status github-runner-nix-config
ssh sentinel journalctl -u github-runner-nix-config -f

# the deploy key reaches the targets as root
ssh sentinel sudo -u github-runner ssh -o BatchMode=yes root@torrens.lan true

# what @auto resolves to
nix eval --impure --json .#colmenaHive.deploymentConfig \
  --apply 'c: builtins.attrNames (builtins.intersectAttrs c (builtins.listToAttrs (map (n: { name = n; value = 1; }) (builtins.attrNames c))))'
```

## Widening it later

Add `"auto"` to a host's `aegix.deploy.tags`. Think twice for `sentinel` (it
would be deploying itself, and a broken deploy kills the runner along with DNS)
and for `aegis` (public reverse proxy, no automatic rollback anywhere in this
pipeline).

## Follow-ups

- [ ] Move the runner to a dedicated VM on `veritas`.
- [ ] No automatic rollback exists. A config that builds, activates, and then
      breaks networking still needs the Proxmox console. `colmena apply boot`
      plus a manual reboot remains the safer path for risky changes.
- [ ] `k8s-1/2/3` are excluded everywhere — they cannot build until `k3s-token`
      exists in `secrets.yaml`.
