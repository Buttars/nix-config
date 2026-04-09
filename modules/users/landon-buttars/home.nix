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

        matchBlocks = {
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

        extraConfig = ''
          Host *
            AddKeysToAgent yes
            UseKeychain yes
            ServerAliveInterval 30
            ServerAliveCountMax 3
        '';
      };

      home.sessionVariables = {
        AVANTE_PROVIDER = "openai";
        AMAZONQ_START_URL = "https://wgu.awsapps.com/start";
        NODE_TLS_REJECT_UNAUTHORIZED = 0;
      };
    };
}
