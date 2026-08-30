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
          devpod
          lazydocker
          nixpkgs-fmt
        ];
      };
  };
}
