{ pkgs, ... }:
{
  environment.systemPackages =
    with pkgs;
    [
      atac
      cargo
      delta
      devenv
      devpod
      dig
      gcc
      git
      gnumake
      go
      lazydocker
      nixpkgs-fmt
      nodejs
      pnpm
      python3
      ripgrep
    ]
    ++ (pkgs.lib.optionals pkgs.stdenv.isLinux
      [
        # julia
      ]
    );

  programs.direnv.enable = true;
}
