{ aegis, ... }:
{
  aegis.programming = {
    includes = [
      aegis.cli
      aegis.cli._.git
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
