# Plain helper, imported explicitly (not an aspect).
#
# dotfiles.mutable = false (default): home-manager owns the files as read-only
# store symlinks.
#
# dotfiles.mutable = true: home-manager stops managing them and seeds real
# writable copies instead, so they can be edited without a rebuild. Existing
# files are never overwritten, so edits survive later rebuilds.
#
# Both branches are defined unconditionally and gated on their values; deciding
# the shape of the returned attrset from `config` causes infinite recursion.
{ config, lib }:
name: files:
let
  configDirs = lib.unique (map (p: builtins.head (lib.splitString "/" p)) (lib.attrNames files));
in
{
  xdg.configFile = lib.mapAttrs (_: src: {
    source = src;
    enable = !config.dotfiles.mutable;
  }) files;

  home.activation = lib.mkMerge [
    {
      # These configs were previously managed as a whole-directory symlink into
      # the store. Home-manager cannot create files inside such a directory and
      # its orphan cleanup does not remove it first, so drop it beforehand.
      # Only ever removes a symlink, never a real directory.
      "dropStaleConfigDirLinks-${name}" = lib.hm.dag.entryBefore [ "linkGeneration" ] (
        lib.concatStringsSep "\n" (
          map (dir: ''
            stale="${config.xdg.configHome}/${dir}"
            if [ -L "$stale" ]; then
              run rm -f "$stale"
            fi
          '') configDirs
        )
      );
    }
    (lib.mkIf config.dotfiles.mutable {
      "seedMutableFiles-${name}" = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatStringsSep "\n" (
          lib.mapAttrsToList (relPath: src: ''
            target="${config.xdg.configHome}/${relPath}"
            if [ ! -e "$target" ]; then
              run mkdir -p "$(dirname "$target")"
              run install -m644 ${src} "$target"
            fi
          '') files
        )
      );
    })
  ];
}
