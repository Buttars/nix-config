{ ... }:
{
  aegix.herdr = {
    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        # Herdr plugins to install at activation time (owner/repo on GitHub).
        plugins = [
          "NathanFlurry/herdr-plugin-jj-workspace"
          "cloudmanic/herdr-plus"
          "smarzban/herdr-file-viewer"
          "persiyanov/herdr-reviewr"
          "paulbkim-dev/vim-herdr-navigation"
          "andrewchng/herdr-sessionizer"
          "yuk1ty/herdr-spreader"
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

        systemd.user.services.herdr = lib.mkIf pkgs.stdenv.isLinux {
          Unit = {
            Description = "Herdr terminal workspace server";
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.herdr}/bin/herdr server";
            Restart = "always";
            RestartSec = 2;
          };
          Install.WantedBy = [ "default.target" ];
        };

        launchd.agents.herdr = lib.mkIf pkgs.stdenv.isDarwin {
          enable = true;
          config = {
            ProgramArguments = [
              "${pkgs.herdr}/bin/herdr"
              "server"
            ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.home.homeDirectory}/.config/herdr/launchd-server.log";
            StandardErrorPath = "${config.home.homeDirectory}/.config/herdr/launchd-server.log";
          };
        };

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

          # Workspace management (defaults leave these unset).
          previous_workspace = "prefix+shift+left"
          next_workspace = "prefix+shift+right"
          switch_workspace = "prefix+shift+1..9"
          close_workspace = "prefix+shift+d"

          # Agent session navigation (direct, sidebar-independent).
          previous_agent = "prefix+shift+up"
          next_agent = "prefix+shift+down"

          navigate_workspace_up = "k"
          navigate_workspace_down = "j"

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
          type = "popup"
          command = "${pkgs.herdr-sessionizer}/bin/herdr-sessionizer"
          description = "workspace picker (zoxide + existing)"
          width = "85%"
          height = "85%"
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

        # Build a combined CA bundle: nix public roots + (on Darwin) any
        # corporate roots exported from the macOS System keychain. Plugin
        # install (below) points CARGO_HTTP_CAINFO/NIX_SSL_CERT_FILE at this
        # file on every platform, so it must exist on Linux too, not just
        # Darwin, or cargo/git TLS verification fails outright.
        home.activation.herdr-cert-bundle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          bundle="${config.home.homeDirectory}/.config/herdr/ca-bundle.crt"
          mkdir -p "$(dirname "$bundle")"
          cat "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" > "$bundle"
          ${lib.optionalString pkgs.stdenv.isDarwin ''
            # Append corporate TLS-inspection roots from the System keychain.
            for cn in "Zscaler Root CA"; do
              /usr/bin/security find-certificate -a -c "$cn" -p \
                /Library/Keychains/System.keychain >> "$bundle" 2>/dev/null || true
            done
          ''}
        '';

        home.activation.herdr-plugins = lib.hm.dag.entryAfter [ "herdr-cert-bundle" ] ''
          # Run inside a subshell so the PATH/cert env changes below stay local
          # to plugin installation. All home.activation blocks share one shell
          # process; prepending /usr/bin ahead of $PATH here (needed so cargo
          # finds the system Xcode clang on Darwin) otherwise leaks into the
          # later setupLaunchAgents step, shadowing GNU coreutils (readlink -m)
          # and silently breaking the sops-nix LaunchAgent update.
          #
          # On Darwin, nix gcc/clang is intentionally left off PATH — cargo
          # needs the system Xcode clang (with the macOS SDK and -liconv) for
          # linking. On Linux there is no such system fallback, so nix's gcc
          # must be on PATH or cargo/cgo builds fail with "linker `cc` not
          # found".
          (
            export PATH="${pkgs.herdr}/bin:${pkgs.cargo}/bin:${pkgs.rustc}/bin:${pkgs.git}/bin:${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.go}/bin:${pkgs.bun}/bin:${pkgs.gawk}/bin:${lib.optionalString pkgs.stdenv.isLinux "${pkgs.gcc}/bin:"}/usr/bin:/bin:$PATH"
            export CARGO_HTTP_CAINFO="${config.home.homeDirectory}/.config/herdr/ca-bundle.crt"
            export NIX_SSL_CERT_FILE="$CARGO_HTTP_CAINFO"
            for plugin in ${lib.concatStringsSep " " plugins}; do
              # Suppress the install preview/output unless the command fails.
              if ! out=$(herdr plugin install "$plugin" --yes 2>&1); then
                echo "herdr: failed to install plugin '$plugin':" >&2
                echo "$out" >&2
              fi
            done
          )
        '';
      };
  };
}
