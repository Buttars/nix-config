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

          OLLAMA_BASE_URL = "http://${config.services.ollama.host}:${toString config.services.ollama.port}";
        };
      };
    };
}
