{
  description = "specify-cli (GitHub Spec Kit) packaged for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        py = pkgs.python311;

        specify-cli = py.pkgs.buildPythonApplication rec {
          pname = "specify-cli";
          version = "0.1.6";

          src = pkgs.fetchFromGitHub {
            owner = "github";
            repo = "spec-kit";
            rev = "v${version}";
            sha256 = pkgs.lib.fakeSha256;
          };

          pyproject = true;
          build-system = [ py.pkgs.hatchling ];

          # From pyproject.toml deps (plus socksio for httpx[socks])
          dependencies = with py.pkgs; [
            typer
            click
            rich
            httpx
            socksio
            platformdirs
            readchar
            truststore
            pyyaml
            packaging
          ];

          pythonImportsCheck = [ "specify_cli" ];

          meta = with pkgs.lib; {
            description = "Specify CLI, part of GitHub Spec Kit (Spec-Driven Development toolkit)";
            homepage = "https://github.com/github/spec-kit";
            license = licenses.mit;
            mainProgram = "specify";
          };
        };
      in
      {
        packages.default = specify-cli;
        packages.specify-cli = specify-cli;

        apps.default = {
          type = "app";
          program = "${specify-cli}/bin/specify";
        };
      }
    );
}
