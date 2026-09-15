{
  aegix.opencode.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ai = import ../lib/_ai-models.nix;
      rulesDir = ./ai/rules;
      ruleFiles = builtins.attrNames (builtins.readDir rulesDir);

      # Render the canonical agents into opencode's agent format. The Kiro
      # dispatcher is skipped (its routing/crew is Kiro-specific); agents with a
      # prompt are switchable ("all"), the rest are subagents.
      agents = import ./ai/_agents.nix;
      ocAgent =
        name: a:
        {
          description = a.description or name;
          mode = if a ? prompt then "all" else "subagent";
        }
        // lib.optionalAttrs (a ? prompt) {
          prompt = builtins.readFile (./ai/prompts + "/${a.prompt}.md");
        };
      ocAgents = lib.mapAttrs ocAgent (removeAttrs agents [ "default" ]);
    in
    {
      home.packages = [ pkgs.opencode ];

      # opencode re-fetches models.dev at runtime, which lacks the (unmerged) kiro
      # provider and overwrites the kiro models baked in at build time. Pin it to
      # the build-time data so the grafted kiro models stay visible.
      home.sessionVariables.OPENCODE_DISABLE_MODELS_FETCH = "true";

      xdg.configFile."opencode/rules".source = rulesDir;

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options.baseURL = "http://127.0.0.1:11434/v1";
          models = lib.mapAttrs (name: m: {
            inherit name;
            inherit (m) contextLength;
          }) (lib.filterAttrs (_: m: m.tools) ai.models);
        };
        model = "ollama/${ai.default}";
        instructions = map (f: "${config.xdg.configHome}/opencode/rules/${f}") ruleFiles;
        agent = ocAgents;
      };
    };
}
