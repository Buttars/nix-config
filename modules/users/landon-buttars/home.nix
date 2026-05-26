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
        logseq
        obsidian
        minikube
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

      home.sessionVariables = {
        EDITOR = "nvim";
        TERMINAL = "kitty";
        BROWSER = "brave";
        AVANTE_PROVIDER = "openai";
        NODE_TLS_REJECT_UNAUTHORIZED = 0;
        DOCKER_HOST = "unix:///Users/landon.buttars/.colima/default/docker.sock";
      };

      programs.zsh.initContent = ''
        if [[ -f "${config.sops.secrets.github-mcp-server.path}" ]]; then
          export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${config.sops.secrets.github-mcp-server.path})"
        fi
      '';
    };
}
