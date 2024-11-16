{ inputs, nixosModule, stateVersion, ... }: {
  mkHome =
    { hostname, username ? "buttars", platform ? "x86_64-linux" }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          hostname
          platform
          username
          stateVersion;
      };
      modules = [ ../home-manager ];
    };

  mkNixos = { hostname, username ? "buttars", platform ? "x86_64-linux", modules ? [ ] }: inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {
        _module.args = inputs;
        nixpkgs = {
          overlays = [
            inputs.self.overlays.additions
            inputs.self.overlays.modifications
            inputs.self.overlays.unstable-packages
          ];
        };
      }
      nixosModule
      ../profiles/common.nix
    ] ++ modules;
    extraModules = [ ];
    specialArgs = {
      inherit
        inputs
        hostname
        platform
        username
        stateVersion;
    };
  };

  forAllSystems = inputs.nixpkgs.lib.getAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
