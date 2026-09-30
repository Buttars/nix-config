{
  aegix.omlx.homeManager =
    { lib, pkgs, ... }:
    let
      version = "0.5.1";
      dmg = pkgs.fetchurl {
        url = "https://github.com/jundot/omlx/releases/download/v${version}/oMLX-${version}-macos26-27.dmg";
        hash = "sha256-CkSvyaJQcPfrWyjJeqP00gTrQGaZfJe06+deVKEepWE=";
      };
    in
    {
      home.packages = with pkgs; [
        (pkgs.writeShellScriptBin "omlx" ''
          exec '/Applications/oMLX.app/Contents/MacOS/omlx-cli' "$@"
        '')
      ];

      home.activation.install-omlx = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        app_dir="/Applications"
        app_name="oMLX.app"
        marker_version="${version}"

        # Guard rather than `exit 0` when already up to date: home.activation
        # blocks share one shell process, so `exit` here would abort every
        # later activation step (e.g. setupLaunchAgents, sops-nix).
        installed_version=""
        if [ -d "$app_dir/$app_name" ]; then
          installed_version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$app_dir/$app_name/Contents/Info.plist" 2>/dev/null || echo "")
        fi

        if [ "$installed_version" != "$marker_version" ]; then
          # Detach any stale attachment of this exact image left by an earlier
          # run. Home Manager activation runs under `set -e`, so a failure
          # after attach used to abort before detach and leak the attachment;
          # once leaked, `hdiutil attach` below fails with "Resource busy".
          for dev in $(/usr/bin/hdiutil info 2>/dev/null | awk -v tgt="${dmg}" \
            '/^image-path/ { cur = (index($0, tgt) > 0) } cur && /\/dev\/disk/ { print $1 }'); do
            /usr/bin/hdiutil detach "$dev" -force >/dev/null 2>&1 || true
          done

          mount_point=$(mktemp -d)
          if /usr/bin/hdiutil attach "${dmg}" -nobrowse -readonly -mountpoint "$mount_point" >/dev/null 2>&1; then
            if [ -d "$mount_point/$app_name" ]; then
              # Remove any existing bundle best-effort. It can be owned by a
              # different account (oMLX self-updates as another user), so this
              # unprivileged activation must not abort the whole switch when it
              # cannot delete foreign-owned files. Clear flags/perms we own,
              # then fall back to moving the bundle aside — that only needs
              # write on /Applications (admin-writable), not on the bundle's
              # inner dirs.
              if [ -e "$app_dir/$app_name" ]; then
                /usr/bin/chflags -R nouchg "$app_dir/$app_name" 2>/dev/null || true
                chmod -R u+w "$app_dir/$app_name" 2>/dev/null || true
                rm -rf "$app_dir/$app_name" 2>/dev/null || true
              fi
              if [ -e "$app_dir/$app_name" ]; then
                stash="$app_dir/.$app_name.old-$$"
                mv "$app_dir/$app_name" "$stash" 2>/dev/null || true
                rm -rf "$stash" 2>/dev/null || true
              fi

              # Copy without -p so the installed bundle is owned by us and
              # writable, making future version bumps removable without sudo.
              if [ ! -e "$app_dir/$app_name" ]; then
                cp -R "$mount_point/$app_name" "$app_dir/$app_name" || true
              fi
            fi

            /usr/bin/hdiutil detach "$mount_point" >/dev/null 2>&1 \
              || /usr/bin/hdiutil detach "$mount_point" -force >/dev/null 2>&1 || true
          fi
          rmdir "$mount_point" 2>/dev/null || true
        fi
      '';
    };
}
