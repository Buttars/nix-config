{ ... }:
{
  aegix.ai.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    lib.mkMerge [
      {
        home.packages = [ pkgs.github-mcp-server ];

        # Contents are a separate repo, intentionally unmanaged here; only the
        # directory is created so a fresh machine has somewhere to clone into.
        home.activation.aiKnowledgeDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/ai-knowledge"
        '';
      }

      (import ./_render/kiro.nix {
        inherit lib;
        agents = import ./_agents.nix;
        mappings = import ./_render/mappings.nix;
        mcpServers = import ./_mcp.nix { inherit pkgs config; };
      })
    ];
}
