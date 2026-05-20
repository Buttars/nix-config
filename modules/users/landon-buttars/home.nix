{
  den.aspects."landon.buttars".homeManager =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = [
        {
          dotfiles.mutable = true;
          dotfiles.path = "${config.home.homeDirectory}/nix-config/master/dotfiles";
        }
      ];

      home.file.".config/nvim" =
        let
          filePath = "${config.dotfiles.path}/.config/nvim";
        in
        {
          source =
            if !config.dotfiles.mutable then
              lib.relativeToRoot "./dotfiles/.config/nvim"
            else
              config.lib.file.mkOutOfStoreSymlink filePath;
          recursive = true;
        };

      home.packages = with pkgs; [
        gleam
        erlang
        sidecar
        td
        # google-chrome
        colima
        git-worktree-switcher
        docker
        amazon-q-cli
        kiro-cli
        logseq
        obsidian
        # firefox
        (pkgs.python3.withPackages (
          ps: with ps; [
            jupyterlab
            ipykernel
            numpy
            pandas
          ]
        ))
      ];

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            extraOptions = {
              AddKeysToAgent = "yes";
              UseKeychain = "yes";
              ServerAliveInterval = "30";
              ServerAliveCountMax = "3";
            };
          };

          "github.com-buttars" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519_personal";
            identitiesOnly = true;
          };

          # Default GitHub = work
          "github.com" = {
            hostname = "github.com";
            user = "git";
            identityFile = "~/.ssh/id_ed25519";
            identitiesOnly = true;
          };
        };
      };

      sops.secrets.github-mcp-server = { };

      home.file.".kiro/settings/mcp.json".text =
        let
          mcp-shell = pkgs.writeShellScript "mcp-shell" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:${pkgs.docker}/bin:${pkgs.awscli2}/bin:$PATH"
            export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
            exec "$@"
          '';
          github-mcp = "${pkgs.github-mcp-server}/bin/github-mcp-server";
        in
        builtins.toJSON {
          mcpServers = {
            github = {
              command = github-mcp;
              args = [ "stdio" ];
              env.GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
            };
            tmux = {
              command = "${mcp-shell}";
              args = [
                "npx"
                "-y"
                "tmux-mcp"
                "--shell-type=zsh"
              ];
            };
            context7 = {
              command = "${mcp-shell}";
              args = [
                "npx"
                "-y"
                "@upstash/context7-mcp"
              ];
            };
            nixos = {
              command = "${mcp-shell}";
              args = [
                "uvx"
                "mcp-nixos"
              ];
            };
            filesystem = {
              command = "${mcp-shell}";
              args = [
                "npx"
                "-y"
                "@modelcontextprotocol/server-filesystem"
                "${config.home.homeDirectory}"
              ];
            };
            docker = {
              command = "${mcp-shell}";
              args = [
                "uvx"
                "mcp-server-docker"
              ];
            };
            kubernetes = {
              command = "${mcp-shell}";
              args = [
                "uvx"
                "awslabs.eks-mcp-server@latest"
                "--allow-write"
                "--allow-sensitive-data-access"
              ];
              env.FASTMCP_LOG_LEVEL = "ERROR";
            };
            aws = {
              command = "${mcp-shell}";
              args = [
                "uvx"
                "awslabs.core-mcp-server@latest"
              ];
              env.FASTMCP_LOG_LEVEL = "ERROR";
            };
          };
        };

      home.sessionVariables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
        BROWSER = "brave";
        AVANTE_PROVIDER = "openai";
        AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
        NODE_TLS_REJECT_UNAUTHORIZED = 0;
      };

      programs.zsh.initContent = lib.mkMerge [
        (lib.mkBefore ''
          eval "$(kiro-cli init zsh pre)"
        '')
        ''
          if [[ -f "${config.sops.secrets.github-mcp-server.path}" ]]; then
            export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${config.sops.secrets.github-mcp-server.path})"
          fi
        ''
        (lib.mkAfter ''
          eval "$(kiro-cli init zsh post)"
        '')
      ];
    };
}
