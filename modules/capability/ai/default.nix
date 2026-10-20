{ __findFile, ... }:
{
  aegix.ai = {
    includes = [
      <aegix/kiro>
      <aegix/opencode>
      <aegix/skills>
    ];

    homeManager =
      {
        lib,
        pkgs,
        config,
        ...
      }:
      let
        agents = import ./_agents.nix;
      in
      lib.mkMerge [
        {
          home.packages = [ pkgs.github-mcp-server ];

          # Contents are a separate repo, intentionally unmanaged here; only the
          # directory is created so a fresh machine has somewhere to clone into.
          home.activation.aiKnowledgeDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/ai-knowledge"
          '';
        }

        (import ./_kiro.nix {
          inherit lib agents;
          mappings = import ./_mappings.nix;
          mcpServers = import ./_mcp.nix { inherit pkgs config; };
        })

        (import ./_opencode.nix {
          inherit lib agents;
          inherit (config.xdg) configHome;
          models = import ../../lib/_ai-models.nix;
        })
      ];
  };
}
