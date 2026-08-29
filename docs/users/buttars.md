# buttars: Remaining Work

Finishing the move of this user's dotfiles into nix-managed aspects, plus one
unresolved question about where session variables should live. User config is
in `modules/users/buttars/`.

## Symlinked configs still coming from the dotfiles input

`modules/users/buttars/dotfiles.nix` still points two configs at the pinned
`dotfiles` flake input. In both cases `<aegix/hyprland>` already installs the
package and, for waybar, defines the systemd user service
(`modules/capability/hyprland/default.nix:40,43,361`) — only the config itself
is still a symlink.

- [ ] `rofi` — move the config into a nix-managed aspect, drop the symlink.
- [ ] `waybar` — same.
- [ ] Once both are migrated, `dotfiles.nix` contains only the nvim symlink.
      Decide whether to keep the file for that alone or fold it into the
      buttars aspect and delete it.

`nvim` is deliberately **not** a migration target: it is a mutable
`mkOutOfStoreSymlink` into `~/Projects/nix-config/dotfiles/.config/nvim` so it
can be edited in place rather than through the store.

## Session variables are duplicated, and the profile meant to own them is unwired

`EDITOR`, `TERMINAL` and `BROWSER` are set in two places:

- `modules/users/buttars/fish.nix:28-30`
- `modules/profile/workstation.nix:8-10`

An earlier note called for moving them out of `fish.nix` into a profile. They
were **copied, not moved** — and the profile never took effect for this user.
`<aegix/workstation>` is included by exactly one thing,
`modules/users/landon-buttars/default.nix:17`; neither `buttars-desktop` nor
`buttars-laptop` includes `<aegix/laptop>`, `<aegix/desktop>` or
`<aegix/workstation>`. So for buttars these values come solely from `fish.nix`,
and deleting them there would silently unset them.

Pick a direction before touching either file:

- [ ] Either wire a profile into the buttars hosts
      (`<aegix/laptop>` / `<aegix/desktop>`, which both pull in
      `<aegix/workstation>`) and then drop the duplicate from `fish.nix`,
- [ ] Or accept that the profile layer is unused, delete
      `modules/profile/{workstation,laptop,desktop,server}.nix` as dead, and
      keep the variables in the user aspect.

## Already resolved

Kept for context so these are not re-investigated:

- `shell` symlink — gone from `dotfiles.nix`.
- `lf` — replaced; yazi now arrives via `cli._.tui` (`programs.yazi`, wrapper `y`).
- `fish.nix` sesh vs the tmux sesh sub-aspect — no duplication; only
  `modules/app/tmux.nix:166` defines it.
- "switch buttars to the kitty sub-aspect" — moot. buttars includes
  `<aegix/terminal-emulator>`, which itself does `includes = [ <aegix/kitty> ]`
  since kitty was promoted to the app layer.
