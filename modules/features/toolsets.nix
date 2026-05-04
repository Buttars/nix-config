# Toggleable Devenv Shells
#
# Each toolset is a self-contained binary (built via mk-shell-bin) that
# drops you into a shell with the specified tools. No flake path or
# `nix develop` invocation needed — just run the command.
#
# Include desired toolsets in a user or host aspect:
#   <aegix/toolsets/terraform>
#   <aegix/toolsets/k8s>
#   <aegix/toolsets/aws>
#   <aegix/toolsets/node>
#   <aegix/toolsets/python>
#
# Then run: dev-terraform, dev-k8s, dev-aws, dev-node, dev-python
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
  aegix.toolsets = {
    _.terraform.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (mkToolset pkgs "dev-terraform" (
            with pkgs;
            [
              terraform
              just
              pre-commit
              tflint
            ]
          ))
        ];
      };
    _.k8s.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (mkToolset pkgs "dev-k8s" (
            with pkgs;
            [
              kubectl
              kubernetes-helm
              k9s
              kubectx
              stern
            ]
          ))
        ];
      };
    _.aws.homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          (mkToolset pkgs "dev-aws" (
            with pkgs;
            [
              awscli2
              ssm-session-manager-plugin
              aws-vault
            ]
          ))
        ];
      };
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
