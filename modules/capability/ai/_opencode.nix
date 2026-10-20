# opencode renderer. Lossy by design: opencode has no per-agent resource scoping,
# so rules are rendered as global instructions and the Kiro dispatcher is dropped
# entirely (its routing table and crew settings have no opencode equivalent).
#
# This owns the whole of opencode.json, provider block included, because
# home-manager allows only one writer per file. "Which models a harness can
# reach" is agent configuration rather than binary configuration, so the split
# falls here rather than in app/opencode.nix.
{
  lib,
  configHome,
  agents,
  models,
}:
let
  ruleFiles = builtins.attrNames (builtins.readDir ./rules);

  mkAgent =
    name: a:
    {
      description = a.description or name;
      mode = "all";
    }
    // lib.optionalAttrs (a ? prompt) { prompt = builtins.readFile (./prompts + "/${a.prompt}.md"); };
in
{
  xdg.configFile."opencode/rules".source = ./rules;

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
    provider.ollama = {
      npm = "@ai-sdk/openai-compatible";
      name = "Ollama";
      options.baseURL = "http://127.0.0.1:11434/v1";
      models = lib.mapAttrs (name: m: {
        inherit name;
        inherit (m) contextLength;
      }) (lib.filterAttrs (_: m: m.tools) models.models);
    };
    model = "ollama/${models.default}";
    instructions = map (f: "${configHome}/opencode/rules/${f}") ruleFiles;
    agent = lib.mapAttrs mkAgent (removeAttrs agents [ "default" ]);
  };
}
