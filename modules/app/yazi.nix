{ aegix, ... }:
{
  aegix.yazi = {
    homeManager =
      { pkgs, lib, ... }:
      let
        # fuse-archive presents the archive as a read-only directory, which is
        # the only way to walk into one from yazi.
        archive-enter = pkgs.writeShellApplication {
          name = "yazi-archive-enter";
          runtimeInputs = [
            pkgs.fuse-archive
            pkgs.util-linux
            pkgs.coreutils
            pkgs.yazi
          ];
          text = ''
            archive=$1
            mnt="''${XDG_RUNTIME_DIR:-/tmp}/yazi-archives/$(basename "$archive")"
            mkdir -p "$mnt"

            if ! mountpoint -q "$mnt"; then
              if ! err=$(fuse-archive "$archive" "$mnt" 2>&1); then
                rmdir "$mnt" 2>/dev/null || true
                echo "cannot open $archive: $err" >&2
                exit 1
              fi
            fi

            ya emit cd "$mnt" || true
          '';
        };

        archive-leave = pkgs.writeShellApplication {
          name = "yazi-archive-leave";
          runtimeInputs = [
            pkgs.util-linux
            pkgs.coreutils
            pkgs.yazi
          ];
          text = ''
            root="''${XDG_RUNTIME_DIR:-/tmp}/yazi-archives"
            [ -d "$root" ] || exit 0

            ya emit cd "$HOME" || true
            for mnt in "$root"/*; do
              [ -d "$mnt" ] || continue
              if mountpoint -q "$mnt"; then
                # pkgs.fuse ships an unprivileged fusermount that cannot unmount.
                /run/wrappers/bin/fusermount -u "$mnt" || true
              fi
              rmdir "$mnt" 2>/dev/null || true
            done
          '';
        };
      in
      {
        home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
          archive-enter
          archive-leave
        ];

        programs.yazi = {
          enable = true;
          shellWrapperName = "y";
          enableZshIntegration = true;
          enableFishIntegration = true;

          settings = {
            mgr = {
              show_hidden = true;
              sort_by = "natural";
              sort_dir_first = true;
            };
          };

          keymap = {
            mgr.prepend_keymap = [
              {
                on = [ "q" ];
                run = "quit";
                desc = "Quit";
              }
              {
                on = [ "<Esc>" ];
                run = "escape";
                desc = "Cancel";
              }
              {
                on = [
                  "T"
                  "c"
                ];
                run = "shell \"7z a archive.zip %s\" --interactive";
                desc = "Compress selection into archive.zip";
              }
              {
                on = [
                  "T"
                  "l"
                ];
                run = "shell \"7z l %h | less\" --block";
                desc = "List archive contents";
              }
            ]
            ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
              {
                on = [
                  "T"
                  "e"
                ];
                run = "shell -- yazi-archive-enter %h";
                desc = "Enter archive";
              }
              {
                on = [
                  "T"
                  "u"
                ];
                run = "shell -- yazi-archive-leave";
                desc = "Close all mounted archives";
              }
            ];
          };
        };
      };
  };
}
