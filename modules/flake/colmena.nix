{ inputs, lib, ... }:
{
  flake-file.inputs.colmena = {
    url = "github:nix-community/colmena";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.colmenaHive =
    let
      nixpkgsFor = lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = [ ];
        }
      );

      nodes = lib.filterAttrs (
        _: cfg: cfg.config.aegix.deploy.targetHost != null
      ) inputs.self.nixosConfigurations;

      versionModule = {
        system.nixos.versionSuffix = inputs.nixpkgs.lib.trivial.versionSuffix;
        system.nixos.revision = inputs.nixpkgs.lib.trivial.revisionWithDefault null;
      };

      deploymentModule =
        { config, ... }:
        {
          deployment = {
            inherit (config.aegix.deploy)
              targetHost
              targetUser
              tags
              buildOnTarget
              ;
          };
        };

      node = cfg: {
        imports = cfg._module.args.modules ++ [
          versionModule
          deploymentModule
        ];
      };
    in
    inputs.colmena.lib.makeHive (
      {
        meta = {
          nixpkgs = nixpkgsFor.x86_64-linux;
          nodeNixpkgs = lib.mapAttrs (_: cfg: nixpkgsFor.${cfg.config.nixpkgs.hostPlatform.system}) nodes;
        };
      }
      // lib.mapAttrs (_: node) nodes
    );
}
