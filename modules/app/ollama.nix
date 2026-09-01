{
  aegix.ollama.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ai = import ../lib/_ai-models.nix;
    in
    {
      services.ollama = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        enable = true;
        package = pkgs.ollama-vulkan;
        host = "127.0.0.1";
        port = 11434;
        loadModels = builtins.attrNames ai.models;
        environmentVariables.OLLAMA_CONTEXT_LENGTH = toString ai.models.${ai.default}.contextLength;
      };
    };
}
