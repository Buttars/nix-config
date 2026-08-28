{ aegix, ... }:
{
  aegix.programming = {
    includes = [
      aegix.cli
      aegix.git
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
