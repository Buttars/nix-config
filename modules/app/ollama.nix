{
  aegix.ollama.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.ollama = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        enable = true;
        package = pkgs.ollama-vulkan;
        host = "127.0.0.1";
        port = 11434;
        loadModels = [ "qwen2.5-coder:7b" ];
      };
    };
}
