# Toggleable Devenv Shells
#
# Each toolset is a self-contained binary (built via mk-shell-bin) that
# drops you into a shell with the specified tools. No flake path or
# `nix develop` invocation needed — just run the command.
#
# Include desired toolsets in a user or host aspect:
#   <aegix/toolsets/node>
#   <aegix/toolsets/python>
#
# Then run: dev-node, dev-python
{ inputs, ... }:
let
  mkToolset =
    pkgs: name: packages:
    let
      shell = inputs.mk-shell-bin.lib.mkShellBin {
        drv = pkgs.mkShell {
          inherit name;
          nativeBuildInputs = packages;
        };
        nixpkgs = pkgs;
      };
    in
    pkgs.writeShellScriptBin name ''
      source ${shell.envScript}
      if [ -n "$NIX_TOOLSETS" ]; then
        export NIX_TOOLSETS="$NIX_TOOLSETS ${name}"
      else
        export NIX_TOOLSETS="${name}"
      fi
      exec $SHELL
    '';
in
{
  flake-file.inputs.mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

  aegix.toolsets = {
    _.node.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (mkToolset pkgs "dev-node" (
            with pkgs;
            [
              nodejs
              pnpm
            ]
          ))
        ];
      };
    _.python.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (mkToolset pkgs "dev-python" (
            with pkgs;
            [
              uv
              ruff
            ]
          ))
        ];
      };
  };
}
