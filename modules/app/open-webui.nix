{
  aegix.open-webui.nixos =
    {
      config,
      lib,
      ...
    }:
    {
      # Setting `environment` replaces the module's defaults, so the telemetry
      # opt-outs have to be repeated here.
      services.open-webui = lib.mkIf config.services.ollama.enable {
        enable = true;
        host = "0.0.0.0";
        port = 8080;
        openFirewall = true;

        environment = {
          SCARF_NO_ANALYTICS = "True";
          DO_NOT_TRACK = "True";
          ANONYMIZED_TELEMETRY = "False";

          # The telemetry flags above only cover analytics. OFFLINE_MODE is what
          # stops the version check and hugging face fetches.
          OFFLINE_MODE = "True";
          ENABLE_COMMUNITY_SHARING = "False";

          OLLAMA_BASE_URLS = lib.concatStringsSep ";" [
            "http://127.0.0.1:${toString config.services.ollama.port}"
            "http://buttars-desktop.lan:${toString config.services.ollama.port}"
          ];
        };
      };
    };
}
