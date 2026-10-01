{ ... }:
{
  aegix.ai.homeManager =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      agents = import ./_agents.nix;
      mcpServers = import ./_mcp.nix { inherit pkgs config; };

      ruleUris = map (r: "file://~/.kiro/steering/${r}.md");
      contextUris = map (c: "file://~/.kiro/context/${c}.md");
      skillUris =
        skills:
        if skills == "all" then
          [
            "skill://~/.kiro/skills/*/SKILL.md"
            "skill://~/.kiro/skills/*/*/SKILL.md"
          ]
        else
          map (s: "skill://~/.kiro/skills/${s}/SKILL.md") skills;

      mkKiroAgent =
        key: a:
        let
          toolsSettings =
            (lib.optionalAttrs (a ? bash) { execute_bash = a.bash; })
            // (lib.optionalAttrs (a ? trustedAgents) {
              crew = {
                trustedAgents = a.trustedAgents;
              };
            });
        in
        {
          name = a.name or key;
        }
        // (lib.optionalAttrs (a ? description) { inherit (a) description; })
        // {
          resources =
            ruleUris (a.rules or [ ]) ++ contextUris (a.context or [ ]) ++ skillUris (a.skills or "all");
        }
        // (lib.optionalAttrs (a ? prompt) { prompt = "file://../prompts/${a.prompt}.md"; })
        // {
          tools = a.tools or [ "*" ];
        }
        // (lib.optionalAttrs (toolsSettings != { }) { inherit toolsSettings; })
        // (
          # Every agent gets all MCP servers by default so spawned subagents
          # have the same tool access as the dispatcher. Opt out or narrow with
          # `mcpServers = [ ... ]` (a list of server names, or [ ] for none).
          let
            sel = a.mcpServers or "all";
          in
          {
            mcpServers = if sel == "all" then mcpServers else lib.getAttrs sel mcpServers;
          }
        )
        // (lib.optionalAttrs (a ? welcomeMessage) { inherit (a) welcomeMessage; });

      agentFiles = lib.mapAttrs' (
        key: a:
        lib.nameValuePair ".kiro/agents/${key}.json" {
          text = builtins.toJSON (mkKiroAgent key a);
        }
      ) agents;
    in
    {
      home.packages = [ pkgs.github-mcp-server ];

      home.file = agentFiles // {
        ".kiro/steering".source = ./rules;
        ".kiro/prompts".source = ./prompts;
        ".kiro/context".source = ./context;
      };
    };
}
