{
  aegix.kiro.homeManager =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.kiro-cli ];

      home.file.".kiro/settings/mcp.json".text =
        let
          mcp-shell = pkgs.writeShellScript "mcp-shell" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:${pkgs.docker}/bin:${pkgs.awscli2}/bin:$PATH"
            export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
            exec "$@"
          '';
          mcp-shell-docker = pkgs.writeShellScript "mcp-shell-docker" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:${pkgs.docker}/bin:${pkgs.awscli2}/bin:$PATH"
            export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
            [ -S "$HOME/.colima/default/docker.sock" ] || exit 0
            exec "$@"
          '';
          mcp-shell-k8s = pkgs.writeShellScript "mcp-shell-k8s" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:${pkgs.docker}/bin:${pkgs.awscli2}/bin:$PATH"
            export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
            [ -S "$HOME/.colima/default/docker.sock" ] && [ -f "$HOME/.kube/config" ] || exit 0
            exec "$@"
          '';
          mcp-shell-atlassian = pkgs.writeShellScript "mcp-shell-atlassian" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:$PATH"
            export JIRA_URL="$ATLASSIAN_SITE_URL"
            export JIRA_USERNAME="$ATLASSIAN_USER_EMAIL"
            export JIRA_API_TOKEN="$ATLASSIAN_API_TOKEN"
            export CONFLUENCE_URL="''${ATLASSIAN_SITE_URL}/wiki"
            export CONFLUENCE_USERNAME="$ATLASSIAN_USER_EMAIL"
            export CONFLUENCE_API_TOKEN="$ATLASSIAN_API_TOKEN"
            exec "$@"
          '';
          mcp-shell-servicenow = pkgs.writeShellScript "mcp-shell-servicenow" ''
            export PATH="${pkgs.nodejs}/bin:${pkgs.uv}/bin:${pkgs.python3}/bin:$PATH"
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
              command = "${mcp-shell-docker}";
              args = [
                "uvx"
                "mcp-server-docker"
              ];
            };
            kubernetes = {
              command = "${mcp-shell-k8s}";
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
                "awslabs.aws-api-mcp-server@latest"
              ];
              env.FASTMCP_LOG_LEVEL = "ERROR";
            };
            atlassian = {
              command = "${mcp-shell-atlassian}";
              # Pin atlassian-python-api <5: mcp-atlassian 0.23.0 declares an
              # unbounded dep, and atlassian-python-api 5.0.0 (2026-08-15)
              # rewrote Confluence into a Cloud dispatcher missing legacy
              # methods, breaking Confluence Cloud tools ("'Cloud' object has no
              # attribute 'get_page_by_id'") and confluence_search.
              # See sooperset/mcp-atlassian#1585. Drop once mcp-atlassian >=0.23.1
              # (which caps the dep, #1589) is released to PyPI.
              args = [
                "uvx"
                "--with"
                "atlassian-python-api==4.0.7"
                "mcp-atlassian"
              ];
            };
            launchdarkly = {
              command = "${mcp-shell}";
              args = [
                "npx"
                "-y"
                "--package"
                "@launchdarkly/mcp-server"
                "--"
                "mcp"
                "start"
                "--api-key"
                "\${LAUNCHDARKLY_ACCESS_TOKEN}"
              ];
            };
            servicenow = {
              command = "${mcp-shell-servicenow}";
              args = [
                "uvx"
                "servicenow-mcp"
              ];
              env = {
                SERVICENOW_INSTANCE_URL = "\${SERVICENOW_INSTANCE_URL}";
                SERVICENOW_AUTH_TYPE = "oauth";
                SERVICENOW_USERNAME = "\${SERVICENOW_USERNAME}";
                SERVICENOW_PASSWORD = "\${SERVICENOW_PASSWORD}";
              };
            };
          };
        };

      programs.zsh.shellAliases.kc = "kiro-cli chat";

      programs.fish.shellAliases.kc = "kiro-cli chat";

      programs.zsh.initContent = lib.mkMerge [
        (lib.mkBefore ''
          eval "$(kiro-cli init zsh pre)"
        '')
        (lib.mkAfter ''
          eval "$(kiro-cli init zsh post)"
        '')
      ];

      programs.fish.interactiveShellInit = lib.mkMerge [
        (lib.mkBefore ''
          kiro-cli init fish pre | source
        '')
        (lib.mkAfter ''
          kiro-cli init fish post | source
        '')
      ];
    };
}
