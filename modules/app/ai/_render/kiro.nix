# Kiro CLI renderer. Everything that knows Kiro's file layout, config schema, and
# tool vocabulary lives here or in ./mappings.nix; the canonical data in
# ../_agents.nix knows none of it. Adding a target means a sibling of this file,
# not an edit to any agent.
{
  lib,
  agents,
  mappings,
  mcpServers,
}:
let
  # The dispatcher's declarations are the universal baseline; every other agent
  # lists only what it adds.
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

  resolveTools = caps: lib.unique (mappings.baseTools ++ lib.concatMap (c: mappings.tools.${c}) caps);

  resolveMcp =
    groups: lib.getAttrs (lib.unique (lib.concatMap (g: mappings.mcp.${g}) groups)) mcpServers;

  mkAgent =
    key: a:
    let
      shell = lib.optionalAttrs (a ? approveReadonlyShell || a ? approvedCommands) {
        execute_bash =
          (lib.optionalAttrs (a ? approveReadonlyShell) { autoAllowReadonly = a.approveReadonlyShell; })
          // (lib.optionalAttrs (a ? approvedCommands) { allowedCommands = a.approvedCommands; });
      };
      toolsSettings =
        shell // (lib.optionalAttrs (a ? trustedAgents) { crew.trustedAgents = a.trustedAgents; });
    in
    {
      name = a.name or key;
    }
    // (lib.optionalAttrs (a ? description) { inherit (a) description; })
    // {
      # Ordered stable-first so the prompt cache survives task-specific content
      # changing underneath it.
      resources =
        standardUris (lib.unique (baselineStandards ++ (a.standards or [ ])))
        ++ ruleUris (lib.unique (baselineRules ++ (a.rules or [ ])))
        ++ contextUris (a.context or [ ])
        ++ skillUris (a.skills or "all");
    }
    // (lib.optionalAttrs (a ? prompt) { prompt = "file://../prompts/${a.prompt}.md"; })
    // (lib.optionalAttrs (a ? tier) { model = mappings.models.${a.tier}; })
    // {
      tools = resolveTools (a.tools or [ ]);
      mcpServers = resolveMcp (a.mcp or [ ]);
    }
    // (lib.optionalAttrs (toolsSettings != { }) { inherit toolsSettings; })
    // (lib.optionalAttrs (a ? hooks) { inherit (a) hooks; })
    // (lib.optionalAttrs (a ? welcomeMessage) { inherit (a) welcomeMessage; });

  agentFiles = lib.mapAttrs' (
    key: a: lib.nameValuePair ".kiro/agents/${key}.json" { text = builtins.toJSON (mkAgent key a); }
  ) agents;
in
{
  home.file = agentFiles // {
    ".kiro/steering".source = ../rules;
    ".kiro/standards".source = ../standards;
    ".kiro/prompts".source = ../prompts;
    ".kiro/context".source = ../context;
  };
}
