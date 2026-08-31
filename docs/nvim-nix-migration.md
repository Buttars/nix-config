# Neovim → Nix migration options

Todo/backlog for moving the Neovim config from mutable dotfiles toward Nix
management. Captured as options rather than a single plan — pick A first, then
B if the extra reproducibility is worth it.

## Current state

- **LazyVim** distro bootstrapped by **lazy.nvim** (clones plugins at runtime).
- **69 plugins** (`dotfiles/.config/nvim/lazy-lock.json`), **33 LazyVim extras**
  enabled (~30 of them language packs: angular, clangd, elixir, go, haskell,
  rust, tex, zig, …), each pulling in LSP + treesitter + formatter + DAP wiring.
- **mason** installs LSP servers/formatters/linters at runtime.
- Config lives in `dotfiles/.config/nvim/` (mutable, symlinked). Nix only
  installs the `neovim` binary + a few tools (`modules/app/neovim.nix`).

## Option A — Minimal reproducibility (~half day)

Keep LazyVim/lazy.nvim; make _tooling_ reproducible via Nix instead of mason.
Lua config stays unchanged.

- [ ] Provide LSP servers, formatters, linters, and DAPs via `home.packages`
      (or a dedicated aspect) for the enabled languages.
- [ ] Disable mason auto-install so it stops fetching binaries into the
      read-only-store environment (rely on tools from PATH).
- [ ] Provide treesitter grammars from Nix
      (`nvim-treesitter.withAllGrammars` or a curated list) instead of runtime
      `:TSInstall`.
- [ ] Keep `lazy-lock.json` committed (already is) to pin plugin commits.
- [ ] Optional: enable the Stylix `neovim` target so the editor matches the
      cyberdream scheme (composes with the existing `capability/theming.nix`).

Result: reproducible tool versions, offline-capable, no mason flakiness.

## Option B — Nix-managed plugins, keep config (~1–2 days)

Load plugins from the Nix store instead of runtime git clones; keep all Lua.
Depends on Option A's tooling work.

- [ ] Adopt `nixCats` or `lazy-nix-helper` to point lazy.nvim at a
      Nix-provided plugin directory (no runtime cloning).
- [ ] Map the 69 plugins to `nixpkgs.vimPlugins`; write `buildVimPlugin`
      derivations for the unpackaged ones (e.g. `sidekick.nvim`,
      `jj-diffconflicts`, `opencode.nvim`).
- [ ] Fold in Option A (tooling + treesitter + mason removal) as a prerequisite.
- [ ] Verify lazy-load behavior still works when plugins resolve to store paths.

Result: no runtime cloning, fully reproducible plugin set; still LazyVim
under the hood.

## Explicitly not doing

- **Full declarative rewrite** in nixvim/nvf (dropping LazyVim): ~3–5 days plus
  permanent hand-maintenance of ~30 language stacks. Not worth losing the
  maintained distro and its upstream updates.
