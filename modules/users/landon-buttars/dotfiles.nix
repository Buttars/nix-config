{ inputs, ... }: {
  den.aspects."landon.buttars".homeManager = 
    let
      inherit (inputs) dotfiles;
    in
    { pkgs, config, lib, ...}: {
      home.file = {
        ".config/nvim" =
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

        ".config/shell" = {
          source = "${dotfiles}/.config/shell";
          recursive = true;
        };
        ".config/fish" = {
          source = "${dotfiles}/.config/fish";
          recursive = true;
        };

        ".config/direnv/direnv.toml".text = lib.mkIf config.programs.direnv.enable ''
          [global]
          hide_env_diff = true
        '';

            ".config/tmux".source = "${dotfiles}/.config/tmux";
            ".config/lf".source = "${dotfiles}/.config/lf";
            ".config/zsh".source = "${dotfiles}/.config/zsh";
            ".config/kitty".source = "${dotfiles}/.config/kitty";
            ".zprofile".source = "${dotfiles}/.config/shell/profile";
            ".config/nixpkgs/config.nix" = {
              text = ''
            {
              allowUnfree = true;
            }
          '';
        };
      };

    };
}
