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

  mkNixos = { 
    hostname, username ? "buttars",
    platform ? "x86_64-linux",
    modules ? [ ],
    systemConfiguration ? inputs.nixpkgs.lib.nixosSystem
  }: systemConfiguration {
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
      ../hosts/nixos/common/core/default.nix
    ] ++ modules;
    specialArgs = {
      inherit
        inputs
        hostname
        platform
        stateVersion;
    };
  };
}
