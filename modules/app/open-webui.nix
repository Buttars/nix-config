{ __findFile, ... }:
{
  aegix.open-webui = {
    includes = [ <aegix/luks-volumes> ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        # The volume predates the container and holds the sqlite db, so it stays
        # where the DynamicUser service left it rather than being copied.
        stateDir = "/var/lib/private/open-webui";

        # A dedicated bridge is what makes the kill switch targetable: filtering
        # docker0 instead would also cut swarmui off from the model downloads it
        # needs.
        network = "open-webui";
        bridge = "owui0";
        subnet = "172.30.0.0/16";

        # Matches the nixpkgs package this replaces. Moving hosts and migrating
        # the schema at the same time would leave no way to tell which one broke.
        version = "0.11.4";

        # The image reads the key from inside DATA_DIR, but the service that
        # wrote this volume kept it one level up, so without this every existing
        # session is signed by a key the container never sees.
        seedSecretKey = pkgs.writeShellScript "open-webui-seed-secret-key" ''
          src=${stateDir}/.webui_secret_key
          dst=${stateDir}/data/.webui_secret_key
          [ -f "$src" ] || exit 0
          [ -e "$dst" ] && exit 0
          ${pkgs.coreutils}/bin/cp -p "$src" "$dst"
        '';
      in
      lib.mkIf config.services.ollama.enable {
        # The layer rules stop an app from pulling in another app, so the host
        # has to bring docker itself.
        assertions = [
          {
            assertion = config.virtualisation.docker.enable;
            message = "open-webui needs docker; include the docker aspect on this host.";
          }
        ];

        virtualisation.oci-containers.backend = lib.mkDefault "docker";

        systemd.services.init-open-webui-network = {
          description = "Create the open-webui docker network";
          wantedBy = [ "multi-user.target" ];
          after = [ "docker.service" ];
          requires = [ "docker.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            ${pkgs.docker}/bin/docker network inspect ${network} >/dev/null 2>&1 && exit 0
            ${pkgs.docker}/bin/docker network create \
              --driver bridge \
              --subnet ${subnet} \
              --opt com.docker.network.bridge.name=${bridge} \
              ${network}
          '';
        };

        virtualisation.oci-containers.containers.open-webui = {
          image = "ghcr.io/open-webui/open-webui:${version}";
          ports = [ "8080:8080" ];

          volumes = [
            "${stateDir}/data:/app/backend/data"
            # The image expects both caches under data/cache/embedding/models,
            # where this volume has nothing. Re-pointing them at the dirs that
            # already hold all-MiniLM-L6-v2 keeps rag working, which it would
            # not if the model had to be fetched again past OFFLINE_MODE.
            "${stateDir}/hf_home:/hf_home"
            "${stateDir}/transformers_home:/transformers_home"
          ];

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

            HF_HOME = "/hf_home";
            SENTENCE_TRANSFORMERS_HOME = "/transformers_home";

            # 127.0.0.1 is the container itself once this is no longer a host
            # service, so ollama has to be named via the bridge gateway.
            OLLAMA_BASE_URLS = lib.concatStringsSep ";" [
              "http://host.docker.internal:${toString config.services.ollama.port}"
              "http://buttars-desktop.lan:${toString config.services.ollama.port}"
            ];
          };

          extraOptions = [
            "--network=${network}"
            "--add-host=host.docker.internal:host-gateway"
          ];
        };

        systemd.services.docker-open-webui = {
          after = [ "init-open-webui-network.service" ];
          requires = [ "init-open-webui-network.service" ];
          serviceConfig.ExecStartPre = lib.mkAfter [ "${seedSecretKey}" ];
        };

        # Every setting above is only a default: a row written by the admin UI
        # wins over the environment, so none of them are a guarantee. Dropping
        # every non-private destination is, and it holds whatever the database
        # says. The unqualified drop covers v6 as well, so enabling ipv6 on the
        # bridge later cannot open a way out.
        networking.nftables.tables.open-webui-kill-switch = {
          family = "inet";
          content = ''
            chain forward {
              type filter hook forward priority filter - 10; policy accept;
              iifname "${bridge}" ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
              iifname "${bridge}" drop
            }
          '';
        };

        networking.firewall.allowedTCPPorts = [ 8080 ];

        aegix.luks-volumes.open-webui = {
          mountPoint = stateDir;
          size = "32G";
          services = [ "docker-open-webui" ];
        };
      };
  };
}
