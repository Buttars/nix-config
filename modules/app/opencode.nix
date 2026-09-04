{
  aegix.opencode.homeManager =
    { lib, pkgs, ... }:
    let
      ai = import ../lib/_ai-models.nix;
    in
    {
      home.packages = [ pkgs.opencode ];

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
      };
    };
}
