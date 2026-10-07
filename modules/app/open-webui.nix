{ __findFile, ... }:
{
  aegix.open-webui = {
    includes = [ <aegix/luks-volumes> ];

    nixos =
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

            # OFFLINE_MODE leaves the OpenAI connection on, and its base URL
            # defaults to api.openai.com, so every model-list refresh calls out
            # even with no API key configured.
            ENABLE_OPENAI_API = "False";
            ENABLE_WEB_SEARCH = "False";
            ENABLE_DIRECT_CONNECTIONS = "False";
            ENABLE_PIP_INSTALL_FRONTMATTER_REQUIREMENTS = "False";

            OLLAMA_BASE_URLS = lib.concatStringsSep ";" [
              "http://127.0.0.1:${toString config.services.ollama.port}"
              "http://buttars-desktop.lan:${toString config.services.ollama.port}"
            ];
          };
        };

        # Every setting above is only a default: a row written by the admin UI
        # wins over the environment, so none of them are a guarantee. Dropping
        # every non-private destination at the cgroup is, and it holds whatever
        # the database says.
        systemd.services.open-webui.serviceConfig = lib.mkIf config.services.ollama.enable {
          IPAddressDeny = "any";
          IPAddressAllow = [
            "localhost"
            "link-local"
            "multicast"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
          ];
        };

        # DynamicUser puts the state behind StateDirectory, so this is the path
        # that has to be encrypted rather than the /var/lib/open-webui symlink.
        aegix.luks-volumes.open-webui = lib.mkIf config.services.ollama.enable {
          mountPoint = "/var/lib/private/open-webui";
          size = "32G";
          services = [ "open-webui" ];
        };
      };
  };
}
