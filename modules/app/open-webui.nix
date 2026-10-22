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

        port = 8080;

        # A dedicated bridge is what makes the kill switch targetable: filtering
        # docker0 instead would also cut swarmui off from the model downloads it
        # needs. The gateway is pinned so ollama can be named by ip, which is
        # what lets the container run with no working resolver at all.
        network = "open-webui";
        bridge = "owui0";
        subnet = "172.30.0.0/16";
        gateway = "172.30.0.1";

        # Matches the nixpkgs package this replaces. Moving hosts and migrating
        # the schema at the same time would leave no way to tell which one broke.
        version = "0.11.4";

        # Reaching the host is an input-hook packet rather than a forwarded one,
        # so this is the one destination the kill switch cannot cover. It is also
        # unavoidable: inference has to happen somewhere, and ollama holds the
        # gpu on the host.
        ollamaUrl = "http://${gateway}:${toString config.services.ollama.port}";

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
              --gateway ${gateway} \
              --opt com.docker.network.bridge.name=${bridge} \
              ${network}
          '';
        };

        virtualisation.oci-containers.containers.open-webui = {
          image = "ghcr.io/open-webui/open-webui:${version}";
          ports = [ "${toString port}:8080" ];

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

            # Every flag above is mirrored into a PersistentConfig row in webui.db
            # and the row wins on the next start, which left openai.enable and
            # community sharing switched on in the database whatever the
            # environment said. This makes the environment the only source.
            ENABLE_PERSISTENT_CONFIG = "False";

            # Held only in the database until now, and its env default is True, so
            # dropping the database as a source would have reopened public signup.
            ENABLE_SIGNUP = "False";

            # Also database-only until now. Kept as the old service set it rather
            # than pointed at chat.buttars.dev, so no link behaviour changes here.
            WEBUI_URL = "http://localhost:${toString port}";

            HF_HOME = "/hf_home";
            SENTENCE_TRANSFORMERS_HOME = "/transformers_home";

            OLLAMA_BASE_URLS = ollamaUrl;
            RAG_OLLAMA_BASE_URL = ollamaUrl;
          };

          extraOptions = [
            "--network=${network}"
            "--add-host=host.docker.internal:host-gateway"

            # Docker's embedded resolver answers from the host's network
            # namespace, so a lookup is the one way out that never crosses the
            # bridge and so never meets the kill switch -- a prompt encoded into
            # query names would leave. Nothing here needs to resolve a name, so
            # the forwarder is pointed into reserved space and given no patience.
            "--dns=240.0.0.1"
            "--dns-option=timeout:1"
            "--dns-option=attempts:1"
          ];
        };

        systemd.services.docker-open-webui = {
          after = [ "init-open-webui-network.service" ];
          requires = [ "init-open-webui-network.service" ];
          serviceConfig.ExecStartPre = lib.mkAfter [ "${seedSecretKey}" ];
        };

        # ENABLE_PERSISTENT_CONFIG makes the flags above authoritative, but they
        # are still only the app deciding where it may connect. This is enforced
        # outside it, so it holds even for a release that ignores one of them.
        # Accepting only established flows lets the reverse proxy keep reaching
        # the port while leaving the container unable to open anything itself --
        # the lan included, which a prompt could otherwise be posted to. The
        # unqualified drop covers v6 and icmp too, so enabling ipv6 on the bridge
        # later cannot open a way out, and the counters make a drop visible
        # without reproducing it from inside the container.
        networking.nftables.tables.open-webui-kill-switch = {
          family = "inet";
          content = ''
            chain forward {
              type filter hook forward priority filter - 10; policy accept;
              iifname "${bridge}" ct state established,related counter accept
              iifname "${bridge}" counter drop
            }
          '';
        };

        networking.firewall.allowedTCPPorts = [ port ];

        aegix.luks-volumes.open-webui = {
          mountPoint = stateDir;
          size = "32G";
          services = [ "docker-open-webui" ];
        };
      };
  };
}
