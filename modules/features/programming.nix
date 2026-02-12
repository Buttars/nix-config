{
  # This aspect provides programming-related tools for Home Manager.
  # Included by: home/* (migrate from home/features/programming.nix)

  aegis.features._.programming = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          atac
          compose2nix
          delta
          devenv
          devpod
          dig
          git
          lazydocker
          nixpkgs-fmt
          ripgrep
        ];

        programs.direnv.enable = true;
      };
  };
}
