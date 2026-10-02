# Server Access Model

How you get a shell on a server, how deploys authenticate, and what to do when
neither works. Covers the four Proxmox VMs that include `<aegix/server>` —
`aegis`, `sentinel`, `torrens`, `theatrum` — and will cover future k8s nodes for
free, since the policy lives in `modules/profile/server.nix` rather than in any
host.

Host addresses and segment layout live in [network.md](network.md); this file
does not repeat them.

## What the policy is

`modules/profile/server.nix`:

- `PasswordAuthentication = false`, `KbdInteractiveAuthentication = false` —
  SSH accepts keys only
- `PermitRootLogin = "prohibit-password"` — root may log in by key, never by
  password
- buttars' public key authorized for `root`, so deploys run as root
- `security.sudo.wheelNeedsPassword = false`
- the per-host user account keeps its `hashedPasswordFile`, now reachable only
  at the console or through `su`

## Why

**The problem was the password, not sudo.** `PasswordAuthentication` was never
set anywhere in this repo, and NixOS defaults it to true. That made the single
shared `buttars-password` secret a valid _network_ credential on all five
servers — one password, guessable from anywhere on the LAN, for every machine.
Turning password auth off was the fix. Passwordless sudo is downstream of it,
not the point of it.

**A sudo password is not a security boundary against a local attacker.** Anyone
with a shell as a wheel user can hijack the SSH agent socket or append to a
shell rc file and wait for the next legitimate `sudo`. The password buys a
delay, not containment.

**Deploying as root removes sudo from the deploy path entirely.** This is what
colmena and deploy-rs do by default. The standard "never permit root login"
advice targets two things: password-guessing against a well-known account name,
and the loss of per-operator audit trails in a team. Key-only auth removes the
first; a single operator removes the second.

**The user password was kept deliberately.** It is the console recovery
credential, it makes the systemd `rescue` and `emergency` targets usable, and
`su` is the fallback if passwordless sudo is ever misconfigured into
unusability. It cannot be replayed over the network, because password auth is
off.

### `PermitRootLogin` — the confusable part

`prohibit-password` is not "disable root login." The four values:

| Value                  | Root may log in                                        |
| ---------------------- | ------------------------------------------------------ |
| `yes`                  | by password or by key                                  |
| `prohibit-password`    | by key only — what these servers use                   |
| `forced-commands-only` | by key, and only to run the key's `command=` directive |
| `no`                   | not at all                                             |

`prohibit-password` is what makes `root@host` deploys work. Setting it to `no`
would break them.

## Verified state

```bash
nix eval --impure --json --expr '
let f = builtins.getFlake "/Users/landon.buttars/Projects/nix-config"; l = f.inputs.nixpkgs.lib;
in l.mapAttrs (n: v: {
  sudoNeedsPw = v.config.security.sudo.wheelNeedsPassword;
  sshPwAuth = v.config.services.openssh.settings.PasswordAuthentication or null;
  rootLogin = v.config.services.openssh.settings.PermitRootLogin or null;
  rootKeys = builtins.length v.config.users.users.root.openssh.authorizedKeys.keyFiles;
}) f.nixosConfigurations'
```

| host                      | sudo needs pw | SSH pw auth | PermitRootLogin   | root keys     | user pw file |
| ------------------------- | ------------- | ----------- | ----------------- | ------------- | ------------ |
| aegis, sentinel, theatrum | false         | false       | prohibit-password | 1             | retained     |
| torrens                   | false         | false       | prohibit-password | 2 (duplicate) | retained     |
| specula                   | **true**      | **true**    | prohibit-password | 0             | retained     |
| workstations              | varies        | true        | prohibit-password | 0             | n/a          |

`prohibit-password` on the hosts with zero root keys is the NixOS default, not a
decision — with no authorized key, root cannot log in by any means.

## The transitional deploy

**`just deploy <host>` fails on a host that has not yet received this config.**
The recipe now targets `root@<host>.lan`, but the root key only lands on the
host _after_ a successful deploy. Until then root has no authorized key and the
connection is refused.

Break the circle once per host by deploying over the old path — as the host's
own user, with sudo:

```sh
nixos-rebuild switch --flake .#<host> --target-host <host>@<host>.lan \
  --sudo --ask-sudo-password --use-substitutes
```

The sudo password prompt still applies during this one deploy:
`wheelNeedsPassword = false` is not in effect until the configuration it is part
of has been activated. After it succeeds, `just deploy <host>` works.

`torrens` is the exception — it already had buttars' key authorized for root at
the host level, so it was reachable as `root@` before this change.

Turning password auth off does not risk locking you out mid-deploy. The SSH
session running the deploy already authenticated with a key, and keeps working
across the activation.

## Recovery

All four servers are Proxmox VMs on `veritas` — identifiable by `ens18` in each
host's `facter.json`. The hypervisor console is the recovery path, and the
retained user password is what gets you in there.

`users.mutableUsers = false` means a `passwd` run from a rescue shell is
reverted on the next activation. Console access buys you diagnosis and a
temporary fix; the durable fix is always a rebuild from this repo.

> **veritas must hold a credential independent of buttars' SSH key.** If
> reaching the hypervisor requires the same key the recovery is meant to
> recover, the plan is circular and there is no recovery path.

## Remaining work

- [ ] Generate a break-glass key, add the `.pub` to
      `modules/users/buttars/keys/`, and authorize it in
      `modules/profile/server.nix`. This is what makes everything below
      reversible, and it comes first.
- [ ] Replace the single shared `buttars-password` with per-host root passwords
      in sops, then lock the user accounts and drop
      `sops.secrets.buttars-password.neededForUsers` from
      `modules/profile/server.nix`. Deliberately deferred: it needs the
      break-glass key and a console login that has actually been tested.
- [ ] Test break-glass once. Boot a server to rescue from the Proxmox console
      and log in. An untested recovery path is not a recovery path.
- [ ] Decide on `specula`. It still has password SSH auth and password sudo. It
      is excluded from the server profile because it is a 512 MB aarch64 Pi,
      and the profile would hand it fail2ban, nftables, wireguard and an open
      port 9100 it has no use for. The access hardening is worth having there;
      the rest of the profile is not.
- [ ] Remove `torrens`' host-level root `keyFiles` entry in
      `modules/hosts/torrens/default.nix`. It now duplicates the profile's, which
      is why the host reports two root keys.

## Deliberately not done

- **Changing the SSH port, and `AllowUsers` allowlists.** Noise reduction, not
  security, on a LAN-only fleet already running fail2ban.
- **Scoping sudoers to specific commands** instead of blanket passwordless.
  Textbook-correct, but it buys nothing once deploys run as root and there is
  one operator.
- **An SSH CA issuing short-lived certificates.** The right answer at 50+ hosts.
  At ten it adds a signing service to maintain, and the Nix configuration is
  already the key distribution mechanism.
