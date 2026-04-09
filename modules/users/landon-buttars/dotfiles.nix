{ inputs, ... }:
{
  den.aspects."landon.buttars".homeManager =
    let
      inherit (inputs) dotfiles;
    in
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
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

        ".config/fish" = {
          source = "${dotfiles}/.config/fish";
          recursive = true;
        };

        ".config/direnv/direnv.toml".text = lib.mkIf config.programs.direnv.enable ''
          [global]
          hide_env_diff = true
        '';

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
