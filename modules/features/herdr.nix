{ ... }:
{
  aegix.herdr = {
    homeManager =
      { pkgs, lib, config, ... }:
      let
        # Herdr plugins to install at activation time (owner/repo on GitHub).
        plugins = [
          "NathanFlurry/herdr-plugin-jj-workspace"
          "cloudmanic/herdr-plus"
          "smarzban/herdr-file-viewer"
          "persiyanov/herdr-reviewr"
          "paulbkim-dev/vim-herdr-navigation"
          "andrewchng/herdr-sessionizer"
        ];
      in
      {

        # herdr itself, plus runtime deps some plugins need on PATH:
        #  - bun: sessionizer plugin runs `bun run ...` at action time
        #  - herdr-sessionizer: zoxide+fzf workspace picker (Alt-s)
        home.packages = [
          pkgs.herdr
          pkgs.bun
          pkgs.herdr-sessionizer
        ];

        # Corporate networks (e.g. Zscaler) do TLS inspection, re-signing HTTPS
        # with a private root CA that lives in the macOS System keychain but not
        # in nix's cacert bundle. Nix's cargo/curl use nix OpenSSL and can't read
        # the keychain, so cargo-based plugin builds fail cert verification.
        #
        # A combined bundle (nix cacert + any corporate roots from the keychain)
        # is generated at activation time (see herdr-cert-bundle below) and
        # pointed to via CARGO_HTTP_CAINFO. The herdr server inherits this from
        # the shell env, so plugin build subprocesses can verify certs.
        home.sessionVariables = {
          CARGO_HTTP_CAINFO = "${config.home.homeDirectory}/.config/herdr/ca-bundle.crt";
          NIX_SSL_CERT_FILE = "${config.home.homeDirectory}/.config/herdr/ca-bundle.crt";
        };

        xdg.configFile."herdr/config.toml".text = ''
          [keys]
          prefix = "ctrl+a"

          [ui]
          sidebar_collapsed_mode = "hidden"
          hide_tab_bar_when_single_tab = true

          [[keys.command]]
          key = "prefix+a"
          type = "plugin_action"
          command = "nathanflurry.jj-workspace.new-tab"
          description = "new jj workspace (in tab)"

          [[keys.command]]
          key = "prefix+shift+a"
          type = "plugin_action"
          command = "nathanflurry.jj-workspace.new"
          description = "new jj workspace"

          [[keys.command]]
          key = "prefix+d"
          type = "plugin_action"
          command = "nathanflurry.jj-workspace.remove"
          description = "remove jj workspace"

          [[keys.command]]
          key = "prefix+f"
          type = "pane"
          command = "herdr-sessionizer"
          description = "workspace picker (zoxide + existing)"
        '';

        # Shell integration for the herdr workflow (zsh + fish):
        #  - Alt-s: run herdr-sessionizer (unified picker: existing workspaces
        #    + zoxide dirs). See pkgs/herdr-sessionizer.nix.
        #  - autostart: on an interactive shell not already inside herdr
        #    ($HERDR_ENV unset), launch the picker (which attaches afterward).
        #    Mirrors the old sesh `if [[ -z "$TMUX" ]]` behavior.
        programs.zsh.initContent = ''
          bindkey -s '\es' '^uherdr-sessionizer\n'

          if [[ -z "$HERDR_ENV" && -o interactive ]]; then
            if [[ "$(uname)" == "Darwin" ]] || [[ ! -o login ]]; then
              herdr-sessionizer
            fi
          fi
        '';

        programs.fish.interactiveShellInit = ''
          bind \es herdr-sessionizer

          if not set -q HERDR_ENV; and status is-interactive
            if test (uname) = Darwin; or not status is-login
              herdr-sessionizer
            end
          end
        '';

        # Build a combined CA bundle: nix public roots + any corporate roots
        # (Zscaler, etc.) exported from the macOS System keychain. This runs
        # before plugin install so CARGO_HTTP_CAINFO points at a valid bundle.
        home.activation.herdr-cert-bundle = lib.mkIf pkgs.stdenv.isDarwin (
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            bundle="${config.home.homeDirectory}/.config/herdr/ca-bundle.crt"
            mkdir -p "$(dirname "$bundle")"
            cat "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" > "$bundle"
            # Append corporate TLS-inspection roots from the System keychain.
            for cn in "Zscaler Root CA"; do
              /usr/bin/security find-certificate -a -c "$cn" -p \
                /Library/Keychains/System.keychain >> "$bundle" 2>/dev/null || true
            done
          ''
        );

        home.activation.herdr-plugins = lib.hm.dag.entryAfter [ "herdr-cert-bundle" ] ''
          # Note: nix gcc/clang is intentionally NOT on PATH — cargo needs the
          # system Xcode clang (with the macOS SDK and -liconv) for linking.
          export PATH="${pkgs.herdr}/bin:${pkgs.cargo}/bin:${pkgs.rustc}/bin:${pkgs.git}/bin:${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.go}/bin:${pkgs.bun}/bin:${pkgs.gawk}/bin:/usr/bin:/bin:$PATH"
          export CARGO_HTTP_CAINFO="${config.home.homeDirectory}/.config/herdr/ca-bundle.crt"
          export NIX_SSL_CERT_FILE="$CARGO_HTTP_CAINFO"
          for plugin in ${lib.concatStringsSep " " plugins}; do
            # Suppress the install preview/output unless the command fails.
            if ! out=$(herdr plugin install "$plugin" --yes 2>&1); then
              echo "herdr: failed to install plugin '$plugin':" >&2
              echo "$out" >&2
            fi
          done
        '';
      };
  };
}
