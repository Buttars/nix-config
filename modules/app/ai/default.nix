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
      map' = import ./_mappings.nix;

      resolveTools = caps: lib.unique (map'.baseTools ++ lib.concatMap (c: map'.tools.${c}) caps);

      resolveMcp = groups: lib.getAttrs (lib.unique (lib.concatMap (g: map'.mcp.${g}) groups)) mcpServers;

      # The default agent's rules are the universal baseline; every other agent
      # declares only what it adds on top.
      baselineRules = agents.default.rules or [ ];
      baselineStandards = agents.default.standards or [ ];

      ruleUris = map (r: "file://~/.kiro/steering/${r}.md");
      standardUris = map (s: "file://~/.kiro/standards/${s}.md");
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
          shell = lib.optionalAttrs (a ? approveReadonlyShell || a ? approvedCommands) {
            execute_bash =
              (lib.optionalAttrs (a ? approveReadonlyShell) {
                autoAllowReadonly = a.approveReadonlyShell;
              })
              // (lib.optionalAttrs (a ? approvedCommands) { allowedCommands = a.approvedCommands; });
          };
          toolsSettings =
            shell
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
          # Ordered stable-first so the prompt cache survives task-specific
          # content changing underneath it.
          resources =
            standardUris (lib.unique (baselineStandards ++ (a.standards or [ ])))
            ++ ruleUris (lib.unique (baselineRules ++ (a.rules or [ ])))
            ++ contextUris (a.context or [ ])
            ++ skillUris (a.skills or "all");
        }
        // (lib.optionalAttrs (a ? prompt) { prompt = "file://../prompts/${a.prompt}.md"; })
        // (lib.optionalAttrs (a ? tier) { model = map'.models.${a.tier}; })
        // {
          tools = resolveTools (a.tools or [ ]);
          mcpServers = resolveMcp (a.mcp or [ ]);
        }
        // (lib.optionalAttrs (toolsSettings != { }) { inherit toolsSettings; })
        // (lib.optionalAttrs (a ? hooks) { inherit (a) hooks; })
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
        ".kiro/standards".source = ./standards;
        ".kiro/prompts".source = ./prompts;
        ".kiro/context".source = ./context;
      };

      # Contents are a separate repo, intentionally unmanaged here; only the
      # directory is created so a fresh machine has somewhere to clone into.
      home.activation.aiKnowledgeDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/ai-knowledge"
      '';
    };
}
