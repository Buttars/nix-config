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

      home.file.".kiro/agents/default.json".text = builtins.toJSON {
        name = "default";
        tools = [ "*" ];
        allowedTools = [
          "fs_read"
          "grep"
          "glob"
          "code"
        ];
        toolsSettings.execute_bash = {
          autoAllowReadonly = true;
          allowedCommands = [
            "jj log.*"
            "jj diff.*"
            "jj show.*"
            "jj status.*"
            "jj config.*"
            "jj bookmark list.*"
            "git log.*"
            "git diff.*"
            "git status.*"
            "git branch.*"
            "git remote.*"
            "git stash list.*"
          ];
        };
      };

      home.file.".kiro/agents/focused-mode.json".text = builtins.toJSON {
        name = "focused-fix";
        description = "Scoped to a single fix or small feature — minimal changes, no cleanup, no extras";
        prompt = "file://../prompts/focused-mode.md";
        tools = [ "*" ];
        welcomeMessage = "Focused mode active. What's the single thing we're fixing?";
      };

      home.file.".kiro/prompts/focused-mode.md".text = ''
        You are operating in focused mode. Your job is to make the smallest possible change to solve the stated problem.

        ## Rules
        - Fix only what is asked — nothing more
        - Do not refactor, clean up, or improve surrounding code
        - Do not create additional files unless absolutely required by the fix
        - Do not add tests, docs, or comments unless explicitly asked
        - If you notice other issues, report them but do not touch them
        - One logical change only — if the fix requires more, stop and ask

        ## When to push back
        If the request is too broad to be a single focused fix, say so and ask the user to narrow it down before proceeding.
      '';

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
