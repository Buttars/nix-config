{
  aegix.opencode.homeManager =
    { pkgs, ... }:
    let
      model = "qwen2.5-coder:7b";
    in
    {
      home.packages = [ pkgs.opencode ];

      xdg.configFile."opencode/opencode.json".text = builtins.toJSON {
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          options.baseURL = "http://127.0.0.1:11434/v1";
          models.${model} = {
            name = model;
            contextLength = 65536;
          };
        };
        model = "ollama/${model}";
      };
    };
}
