{ aegix, ... }:
{
  aegix.programming = {
    includes = [
      aegix.cli
      aegix.cli._.git
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          atac
          compose2nix
          devenv
          devpod
          lazydocker
          nixpkgs-fmt
        ];
      };
  };
}
