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
    in
    {
      home.packages = [ pkgs.opencode ];

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
      };
    };
}
