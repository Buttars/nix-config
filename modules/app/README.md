# app/ — one program or service each

The **third** layer. Each file configures exactly one program or service and
stands on its own.

**Test:** _"Can I name the binary or the systemd unit?"_ — `kitty`, `fish`,
`neovim`, `syncthing`, `sops`, `jj`, …

**Goes here:** a single program/service as `app/<name>.nix` declaring
`aegix.<name>` (one aspect per file). Alternatives are **separate** apps
(`kitty` vs `alacritty`); a `capability/` picks between them. Internal facets of
one app stay nested in its file (`zsh._.vi-mode`, `tmux._.gitmux`).

**Dependencies:** may include `base/` only. Including a `capability/` (pointing
upward) is forbidden.

Full reference: [docs/architecture/module-structure.md](../../docs/architecture/module-structure.md)
