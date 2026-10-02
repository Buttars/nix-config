# Server Access — Runbook

Servers are SSH key-only with passwordless sudo; deploys run as `root`. Policy
lives in `modules/profile/server.nix`, so it applies to any host including
`<aegix/server>` — currently `aegis`, `sentinel`, `torrens`, `theatrum`.

The per-host user keeps its password: it is the Proxmox console credential and
cannot be used over the network.

## Do this first: one transitional deploy per host

`just deploy <host>` targets `root@`, but the root key only lands _after_ a
successful deploy. Break the circle once per host:

```sh
nixos-rebuild switch --flake .#aegis    --target-host aegis@aegis.lan       --sudo --ask-sudo-password --use-substitutes
nixos-rebuild switch --flake .#sentinel --target-host sentinel@sentinel.lan --sudo --ask-sudo-password --use-substitutes
nixos-rebuild switch --flake .#theatrum --target-host theatrum@theatrum.lan --sudo --ask-sudo-password --use-substitutes
nixos-rebuild switch --flake .#torrens  --target-host torrens@torrens.lan   --sudo --ask-sudo-password --use-substitutes
```

The sudo prompt still applies here — `wheelNeedsPassword = false` isn't active
until the config it belongs to is. After each succeeds, `just deploy <host>`
works with no prompt.

## Follow-up work

- [ ] Add a break-glass key — do this first, it makes the password removal
      reversible. Commands below.
- [ ] Test break-glass: boot a server to rescue from the Proxmox console on
      `veritas` and log in. Untested recovery isn't recovery. Note
      `users.mutableUsers = false` means a `passwd` there won't survive the next
      activation.
- [ ] Replace the shared `buttars-password` with per-host root passwords.
      Commands below.
- [ ] Decide on `specula` — still has password SSH auth and password sudo. It is
      excluded from the server profile on purpose (512 MB aarch64 Pi; the
      profile would add fail2ban, nftables, wireguard and an open `:9100`). The
      access hardening is worth having there, the rest of the profile isn't.
- [ ] Remove torrens' duplicate root key in
      `modules/hosts/torrens/default.nix`. It now duplicates the profile's,
      which is why that host reports two.
- [ ] Confirm `veritas` holds a credential independent of the buttars key. It is
      the recovery path for all four VMs; if reaching it needs the same key, the
      plan is circular.

### Break-glass key

```sh
ssh-keygen -t ed25519 -C break-glass -f ~/.ssh/breakglass_ed25519
cp ~/.ssh/breakglass_ed25519.pub modules/users/buttars/keys/
```

Then add it to `keyFiles` in `modules/profile/server.nix` — for both `root` and
the per-host user — and deploy.

### Per-host root passwords

```sh
mkpasswd -m sha-512
sops modules/app/sops/secrets.yaml   # add root-password-<host> per host
```

Then lock the user accounts and drop
`sops.secrets.buttars-password.neededForUsers` from
`modules/profile/server.nix`.

## Check current state

```sh
nix eval --impure --json --expr '
let f = builtins.getFlake "/Users/landon.buttars/Projects/nix-config"; l = f.inputs.nixpkgs.lib;
in l.mapAttrs (n: v: {
  sudoNeedsPw = v.config.security.sudo.wheelNeedsPassword;
  sshPwAuth = v.config.services.openssh.settings.PasswordAuthentication or null;
  rootLogin = v.config.services.openssh.settings.PermitRootLogin or null;
  rootKeys = builtins.length v.config.users.users.root.openssh.authorizedKeys.keyFiles;
}) f.nixosConfigurations'
```

Servers should report `sudoNeedsPw=false`, `sshPwAuth=false`,
`rootLogin=prohibit-password`, `rootKeys>=1`.

`prohibit-password` permits root by key and refuses root by password — it is not
`no`, which would break deploys.
