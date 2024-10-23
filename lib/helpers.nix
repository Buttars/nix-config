{ inputs, stateVersion, ... }: {
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
    specialArgs = {
      inherit
        inputs
        hostname
        platform
        username
        stateVersion;
    };

    modules = [ ../hosts/nixos ] ++ modules;
  };

  forAllSystems = inputs.nixpkgs.lib.getAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];
}
