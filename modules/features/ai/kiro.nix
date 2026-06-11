{
  aegix.ai._.kiro.homeManager =
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
            launchdarkly = {
              command = "${mcp-shell}";
              args = [
                "npx"
                "-y"
                "@launchdarkly/mcp"
              ];
              env.LAUNCHDARKLY_ACCESS_TOKEN = "\${LAUNCHDARKLY_ACCESS_TOKEN}";
            };
          };
        };

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
