# Module Structure

Date: 2026-08-27
Status: Adopted — migration complete

How `modules/` is organized, what each directory means, and where a new file goes.

## Why this exists

Before this document there was no way to tell what belonged at `modules/` root versus `modules/features/`. Eight aspects sat at root (`disks`, `fail2ban`, `hyprland`, `networking`, `power-management`, `wayland`, `sops/`, half of `devenv`) that were structurally indistinguishable from the forty in `features/` — `fail2ban.nix` has the same shape as `features/syncthing.nix`.

The deeper problem was that `features/` was a single flat bag holding three different kinds of thing: single programs (`kitty`, `slack`), groupings that make a capability usable (`terminal-emulator`, `programming`), and machine-level settings that aren't programs at all (`locale`, `networking`). Nothing expressed which was which, or what was allowed to depend on what.

**Den does not enforce any of this.** `<aegix/foo>` is not a path — `den.lib.__findFile` turns it into an attribute lookup on `config.den.ful.aegix.foo`. File location is pure convention, which is exactly why the convention drifted, and why it now has to be written down and checked.

## The layers

```
modules/
├── den.nix           den bootstrap + namespace + global nixos imports
├── defaults.nix      den.default
├── ci-noboot.nix     den.default, CI variant
├── _hm-dotfiles.nix  plain HM options module, imported by defaults.nix
├── flake/            dendritic devenv formatter overlays
├── profile/          workstation laptop desktop server
├── capability/       browser programming hyprland terminal-emulator ...
├── app/              kitty brave fish neovim slack ...
├── platform/             locale networking fonts xdg wayland nix-ls
├── hardware/         nvidia audio zsa            <- outside the stack
├── lib/              disks.nix                   <- outside the stack
├── hosts/            one directory per machine
└── users/            one directory per user
```

| Layer        | Holds                                       | Test                                         |
| ------------ | ------------------------------------------- | -------------------------------------------- |
| `profile`    | Named bundles a machine opts into           | "What role does this machine play?"          |
| `capability` | Groupings that make something usable        | "What can this machine do?"                  |
| `app`        | One program or service                      | "Can I name the binary or the systemd unit?" |
| `platform`   | Machine-level settings that aren't programs | "Is this config with no program behind it?"  |

There is deliberately **no `aegix/` parent directory.** It would mirror nothing — `<aegix/kitty>` lives at `app/kitty.nix`, not `aegix/kitty.nix` — and den never looks at paths anyway, since `namespace "aegix"` takes a string.

## Siblings outside the stack

These are not layers. They have no ordering relationship to anything.

- **`hardware/`** — device and driver enablement. Hardware answers "what physical machine is this," not "how much abstraction is this." Empirically this is already how it behaves: `nvidia`, `zsa`, and `audio` are included _only by hosts, directly_, never by a capability or profile.
- **`lib/`** — functions rather than aspects. `aegix.disks.provides.btrfs` is _called_ (`<aegix/disks/btrfs> { device = ...; }`), not included, so it does not participate in layering at all.

## Dependency rule

```
ALLOWED                          FORBIDDEN
  profile    -> capability         profile -> app        (skips a layer)
  profile    -> profile            app     -> capability (points upward)
  capability -> app, platform          platform    -> anything
  capability -> capability
  app        -> platform

SIBLINGS  hardware/ and lib/ are reachable from any layer and from hosts.
HOSTS     not part of the stack; may include any layer plus siblings.
```

## Where does a new file go?

Every `.nix` under `modules/` is auto-imported by import-tree as a flake-parts module, unless any component of its path starts with `_`. There is no import graph — adding a file is how you load it. Answer in order:

1. **Declares `aegix.<name>`?** → pick the layer using its test above → `modules/<layer>/<name>.nix`
2. **Declares `den.hosts.*` or `den.aspects.<host>`?** → `modules/hosts/<hostname>/`
3. **Declares `den.aspects.<user>`?** → `modules/users/<username>/`
4. **Declares `den.default`, `den.schema`, or den bootstrap?** → `den.nix`, `defaults.nix`, or `ci-noboot.nix`. **Never add a loose `.nix` at `modules/` root** — root holds only those bootstrap files and the category directories.
5. **A flake-parts output not tied to an entity** (`perSystem.*`, `flake.*`, a flake-parts module import, standalone `flake-file.inputs`)? → `modules/flake/`. Exception: an output that closes over one specific entity lives with that entity, e.g. `perSystem.packages.vm` in `modules/hosts/vm/default.nix`.
6. **A plain NixOS / home-manager / darwin module** (raw `options`/`config`, no `den.*`, no `aegix.*`)? → prefix it `_` and import it explicitly from its consumer.

## Other placement rules

**One aspect per file, one file per aspect.** If you are adding `aegix.foo` to a file that is not `<layer>/foo.nix`, you are creating the split-aspect problem this layout exists to prevent.

**Flat within a layer.** Use `<layer>/X/default.nix` only when the aspect owns data files (`capability/hyprland/`, `app/sops/`) or has enough sub-aspects to be worth splitting.

**`_` prefix.** import-tree skips any path containing `/_`, so `_foo.nix` skips one file and `_dir/` skips a whole subtree. Use it _only_ for plain modules pulled in via an explicit `imports = [ ./_x.nix ];` — `_disko.nix`, `_stylix.nix`, `_hm-dotfiles.nix`.

> **Never `_`-prefix a file that declares `den.*` or `aegix.*`.** Those files are reached _only_ by auto-import; prefixing one deletes it from the build with no error. `modules/hosts/*/hardware-configuration.nix` declares `den.aspects.<host>.nixos` despite its name — it must stay unprefixed.

Non-`.nix` files are never imported, so `_` on them means nothing. Don't use it there.

**`__findFile`** must appear in the argument pattern of any module using `<...>` syntax. `deadnix` is configured with `--no-lambda-pattern-names` to preserve it.

**`flake-file.inputs`** goes in the single module that consumes the input. If it has several consumers, declare it where it is imported globally — `modules/den.nix` for `stylix`/`disko`/`home-manager`, `modules/flake/*` for flake-parts modules. Never create a file whose only job is declaring an input. Run `nix run .#write-flake` after any change; `checks.check-flake-file` enforces that `flake.nix` matches.

**Two sub-aspect patterns, kept distinct.** `_.` currently does two unrelated jobs:

- _Alternative implementations_ belong in `app/` as real aspects. `capability/terminal-emulator.nix` does `includes = [ <aegix/kitty> ]`; `app/kitty.nix` and `app/alacritty.nix` stand on their own.
- _Internal facets_ stay nested in their own file — `zsh._.vi-mode`, `fish._.aliases`, `tmux._.gitmux`. These are not apps.

## Classification

**`profile/`** — workstation, laptop, desktop, server

**`capability/`** — terminal-emulator, virtualization, toolsets, ai, cli, programming, hyprland, niri, gaming, printing3d, theming, backup, reticulum, cloud

**`app/`** — fish, zsh, neovim, tmux, yazi, taskwarrior, slack, discord, element-desktop, syncthing, fail2ban, github-mcp-server, herdr, paneru, aerospace, nfs-utils, sops, devenv, and the alternatives promoted out of `_.`: kitty, alacritty, brave, google-chrome, keepassxc, bitwarden, docker, libvirtd, claude, chatgpt, kiro, omlx, skills, git, jj

**`platform/`** — locale, networking, fonts, xdg, wayland, nix-ls

**`hardware/`** — nvidia, audio, zsa

**`lib/`** — disks

### Judgement calls worth revisiting

These are opinions, not facts:

- **`audio`** — in `hardware/` because hosts include it directly like `nvidia`, but it is really `services.pipewire`, i.e. a service. Could equally be `app/`.
- **`sops`** — in `app/` since it configures the sops-nix tool; arguably `platform/` as secrets infrastructure.
- **`theming`** — in `capability/` since it coordinates stylix + qt + gtk; arguably `platform/` as cross-cutting appearance config.
- **`cli._.tui`** — a bundle of TUI programs, so a capability rather than an app. Left nested; promote to `capability/tui` later or leave as is.
- **`toolsets._.{node,python}`** — left nested. They are generated dev-shell binaries sharing a `mkToolset` builder, so they are facets of one mechanism rather than independent apps. Promoting them would mean extracting the builder into `lib/` first.
- **`browser` and `password-manager`** — deleted as capabilities. Nothing included them bare, only their alternatives, so nothing remained after promotion. `virtualization` and `terminal-emulator` were included bare and survive as thin capabilities.
- **`devenv`** — in `app/` (direnv + the devenv package); could be `capability/`.
- **`power-management`** — included by nobody. Dead code; delete rather than classify.

## Naming rationale

`classes` and `aspect` were considered and rejected. Both are load-bearing den vocabulary, and one collides inside this repo:

- **`classes`** is a field in all 8 host files (`classes = [ "homeManager" ]`) and at `modules/defaults.nix` (`den.schema.user.classes`). In den it means the module evaluation domain — `nixos`, `homeManager`, `darwin`.
- **`aspect`** is den's word for _every_ unit here. `<aegix/kitty>`, `<aegix/workstation>`, and `<aegix/locale>` are all aspects, so an `aspect/` directory sitting next to `app/` — which also holds aspects — divides nothing.

`profile` is the nixos-hardware term for exactly this concept: a named bundle a machine opts into.

## Enforcement

Two structural checks, wired into `checks`:

```bash
# 1. one aspect, one file
grep -rhoE '^\s{0,4}aegix\.[a-zA-Z0-9_-]+' modules/ | sed 's/.*aegix\.//' \
  | sort | uniq -c | awk '$1 > 1'

# 2. layer direction: for each file under modules/<layer>/, resolve every
#    <aegix/X> bracket to the layer owning X.nix and assert the edge is
#    permitted. Siblings hardware/ and lib/ are always permitted.
```

## Migration

Ordered so each step is independently verifiable. Path references are fixed within the step that moves the file.

1. Move flake-parts plumbing into `modules/flake/` — includes the `../overlays` → `../../overlays` fix, the devenv split, re-homing the `mk-shell-bin` input, folding away `dotfiles.nix`
2. Sort the aspect library into layered directories — bulk move, plus the `formatter.nix` treefmt exclude and the `.sops.yaml` `path_regex` (path-coupled, same commit)
3. Promote capability alternatives to the app layer — plus 22 bracket updates
4. Rename `default.nix` → `defaults.nix`; fix the double-loaded home-manager dotfiles module
5. Move the vm host out of the modules root
6. Merge the two split aspects — `hyprland`, `workstation`
7. Add the layer-direction check
8. Documentation — this file, CLAUDE.md, README and `docs/` path fixes

### Sharp edges

1. **`modules/overlays.nix:3`** — the only relative-path depth break. `import ../overlays` → `import ../../overlays`. Miss it and every host fails to evaluate.
2. **`modules/formatter.nix:63`** — hardcoded `"modules/sops/secrets.yaml"` exclude, under `settings.on-unmatched = "fatal"`. A stale value breaks both `nix run .#fmt` and `checks.treefmt`.
3. **`.sops.yaml:26`** — `path_regex: modules/sops/…` is an unanchored substring match that stops matching the new path. **Invisible to `nix flake check`** — nothing builds wrong, you just silently lose the ability to rotate secrets.
4. **`modules/defaults.nix`** — the `imports = [ ./home-manager/dotfiles.nix ]` line must be repointed at `./_hm-dotfiles.nix`.
5. **`mk-shell-bin`** is consumed by `features/toolsets.nix` but declared in `modules/devenv.nix`; splitting devenv orphans it.
6. **`stylix`** is imported globally at `den.nix:12` but its `flake-file.inputs` is declared only in `hosts/buttars-desktop/default.nix` — deleting that host would break every other host. Move the declaration to `den.nix`.

### Verification

This is a pure refactor, so **every host's `.drv` hash must be byte-identical before and after** — a proof rather than a heuristic. The flake's `self` outPath does not reach any host derivation: data files like `wallpaper.jpg` and `secrets.yaml` are re-added via `builtins.path`, content-addressed by basename or target, and `facter.json` is read at eval time and never enters a derivation.

```bash
nix eval --impure --json --expr '
  let f = builtins.getFlake "/home/buttars/Projects/nix-config";
      l = f.inputs.nixpkgs.lib;
  in {
    hosts = (l.mapAttrs (_: v: v.config.system.build.toplevel.drvPath) f.nixosConfigurations)
         // (l.mapAttrs (_: v: v.config.system.build.toplevel.drvPath) f.darwinConfigurations);
    formatter = f.formatter.x86_64-linux.drvPath;
    devShell  = f.devShells.x86_64-linux.default.drvPath;
    packages  = builtins.attrNames f.packages.x86_64-linux;
    overlays  = builtins.attrNames f.overlays;
    checks    = builtins.attrNames f.checks.x86_64-linux;
    aegix     = builtins.attrNames f.denful.aegix;
  }' > after.json
diff <(jq -S . before.json) <(jq -S . after.json)
```

All 9 hosts must match: `aegis`, `buttars-desktop`, `buttars-laptop`, `sentinel`, `specula`, `theatrum`, `torrens`, `vm`, `DRHCDGTHGJ`. Cross-platform _evaluation_ works locally, and identical drv hashes prove identical builds, so no remote builder is needed.

Two diffs are expected and should be confirmed rather than assumed: step 2 changes `formatter`/`packages.fmt`/`checks.treefmt` via the treefmt exclude string, and step 3 changes the `aegix` attribute-name list. Hosts must stay identical through both.

Checks that drv-hashing cannot cover:

- `nix run .#write-flake && git diff --exit-code flake.nix` — proves the input relocations changed nothing
- `nix run .#fmt` exits 0 and leaves the tree clean
- `sops updatekeys --yes modules/app/sops/secrets.yaml` — the real test of the `.sops.yaml` regex
- `nix flake check --impure`, and `nix run .#vm` after step 5

## Deferred follow-ups

- **Split the layers into separate den namespaces** — `<profile/laptop>`, `<capability/browser>`, `<app/kitty>`, `<platform/locale>`, registered via `inputs.den.namespace` in `den.nix`. With no `aegix/` parent directory this is _purely_ registering namespaces and rewriting brackets, with zero file movement. It would make the layer visible at every use site and let the direction check become structural rather than grep-based.
- **Decompose `capability/hyprland`** into `app/{waybar,rofi,hyprlock,swaync,wlogout,hyprpaper}` so `niri` can share them instead of redeclaring. Excluded from the migration above to keep it a provable no-op.
- **Clear den's deprecated `provides` fallback** for the remaining nested facets — `aegix.zsh.prompt` rather than `aegix.zsh._.prompt`. Den warns: `bracket path uses 'provides.X' — migrate to direct nesting`.
- **Delete unincluded aspects** — `power-management`, `discord`, `element-desktop`, `locale`, `niri`, `nix-ls`, `paneru`, `tmux`, `xdg`, and the unused `laptop`/`desktop`/`server` profiles. Needs its own audit.
