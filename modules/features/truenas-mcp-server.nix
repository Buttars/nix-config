{
  aegix.truenas-mcp-server = {
    nixos =
      { ... }:
      {
        sops.secrets.truenas-api-key = {
          group = "users";
          mode = "0440";
        };
      };

    homeManager =
      { pkgs, lib, ... }:
      let
        truenas-mcp-wrapper = pkgs.writeShellScript "truenas-mcp" ''
          export TRUENAS_API_KEY="$(cat /run/secrets/truenas-api-key)"
          export TRUENAS_URL="truenas"
          exec ${pkgs.truenas-mcp}/bin/truenas-mcp "$@"
        '';
      in
      {
        # Expose wrapper at a stable path so the claude.json registration
        # doesn't need to change when the Nix store path changes.
        home.file.".local/bin/truenas-mcp".source = truenas-mcp-wrapper;

        # Register the MCP server with Claude Code using the stable path.
        # claude mcp add writes to ~/.claude.json; we only add if missing to
        # avoid clobbering the existing entry on every activation.
        home.activation.truenasMcpRegister = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          stablePath="$HOME/.local/bin/truenas-mcp"
          if ! ${pkgs.claude-code}/bin/claude mcp list 2>/dev/null | grep -q "^truenas:"; then
            ${pkgs.claude-code}/bin/claude mcp add --scope user truenas "$stablePath" 2>/dev/null || true
          fi
        '';
      };
  };
}
