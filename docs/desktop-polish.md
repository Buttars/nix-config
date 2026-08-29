# Desktop: outstanding polish

Refinements to the Hyprland desktop that are known-wanted but not yet done.
Config lives in `modules/capability/hyprland/default.nix` unless noted.

## Wallpapers should ship in the repo

Today wallpapers are **only** on-device. `modules/app/wallpaper.nix:8` points
`random-wallpaper` at `~/Pictures/wallpapers`, and the aspect creates nothing
but a `.keep` there (`:52`). A fresh install therefore has an empty pool and
falls through to the single `fallback` image at
`~/.config/hypr/wallpaper.jpg` — so a rebuilt machine silently loses every
wallpaper the old one had.

Note the repo already carries one image, but for a different purpose:
`modules/capability/hyprland/wallpaper.jpg` is the **stylix palette source**
(`modules/capability/theming.nix:26`), not a member of the rotation pool.

Wanted: a repo-tracked set as the baseline, with the on-device directory kept
as a **secondary, per-device** source layered on top rather than replaced.

- [ ] Add a tracked wallpaper directory (`modules/app/wallpaper/` or a
      top-level `wallpapers/`) and install it into the store.
- [ ] Make `random-wallpaper` pick from **both** the store set and
      `~/Pictures/wallpapers`, so a host can add local images without
      committing them. The script already takes `WALLPAPER_DIR`; it needs to
      become a search path rather than a single directory.
- [ ] Decide precedence — union (device images are extra) is the intent here,
      not override.

Two constraints that shaped the current design and still apply:

- jj's `snapshot.max-new-file-size` defaults below these files; a 3.6MB image
  was **silently dropped** once already. Either commit resized images or set
  the limit in `.jj/repo/config.toml` as part of the change.
- Large binaries in-tree bloat every `nix flake` eval that copies the source.
  Resizing to the target display resolution before committing is worth it.

## Default window width should be ~3/5 of the screen

The scrolling layout's `column_width` is **never set**, so it uses the
built-in default of `0.5`. Verified live:

```
scrolling:column_width   float: 0.500000  set: false
```

- [ ] Set `scrolling.column_width = 0.6` in the `scrolling` block
      (`modules/capability/hyprland/default.nix:165`).
- [ ] Consider re-centring `scrolling.explicit_column_widths` to match — it is
      also unset, defaulting to `0.333, 0.5, 0.667, 1.0`. Something like
      `0.4, 0.6, 0.8, 1.0` keeps the cycle presets aligned with the new
      default.

## Windows should fill the screen, with a keybind to centre the focused one

Currently `focus_fit_method = 0` (centre) at `:168`. Wanted is roughly the
inverse of today's behaviour: columns should **fill the available screen space
most of the time**, with centring available on demand rather than always on.

- [ ] Investigate the other `focus_fit_method` values — is `1` (fit) the only
      alternative, or does this Hyprland version expose more?
- [ ] Add an explicit "centre the focused window" keybind, since centring
      stops being automatic.

**Read the existing comment before changing this.** `focus_fit_method = 0` was
chosen deliberately: the comment at `:166-167` records that `fit` _"aligns a
column to the viewport edge, which slams the window left on unfullscreen."_
Switching to `1` reintroduces that. Confirm whether it is still reproducible on
the current Hyprland before concluding the setting is simply wrong.

Related binds that already exist and may cover part of this:

- `Super+Shift+C` — `fit active`, active column fills the screen (`:255`)
- `Super+O` — `fit expand`, expand column into free space (`:251`)

So "fill the screen" may be partly a question of **which behaviour is the
default** rather than which dispatchers exist.
