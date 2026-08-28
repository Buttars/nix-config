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
          mount_point=$(mktemp -d)
          /usr/bin/hdiutil attach "${dmg}" -nobrowse -readonly -mountpoint "$mount_point" >/dev/null 2>&1

          if [ -d "$mount_point/$app_name" ]; then
            rm -rf "$app_dir/$app_name"
            cp -pR "$mount_point/$app_name" "$app_dir/$app_name"
          fi

          /usr/bin/hdiutil detach "$mount_point" >/dev/null 2>&1
          rmdir "$mount_point" 2>/dev/null || true
        fi
      '';
    };
}
