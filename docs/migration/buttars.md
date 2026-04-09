# Buttars User: Dotfile Migration

Migrate remaining dotfile symlinks in `modules/users/buttars/dotfiles.nix` to nix-managed aspects.

## Remaining Symlinks

- [ ] `shell` — migrate to `<aegis/zsh>` (or fish equivalent), remove symlink
- [ ] `lf` — replace with `<aegis/yazi>`, remove symlink
- [ ] `nvim` — keep as mutable symlink for now

## Environment Variables

- [ ] Move `EDITOR`, `TERMINAL`, `BROWSER` from `buttars/fish.nix` to host or user-level session variables

## Cleanup

- [ ] Remove `buttars/dotfiles.nix` once all symlinks are migrated
- [ ] Verify `buttars/fish.nix` sesh config doesn't duplicate `<aegis/tmux>` sesh sub-aspect
- [ ] Consider switching `buttars` to `<aegis/terminal-emulator/kitty>` (currently uses base which defaults to kitty)
