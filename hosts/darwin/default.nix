{ inputs, stateVersion, ... }: {
  "N4FQ62JR4D" = inputs.darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs stateVersion;
      dotfiles = inputs.dotfiles;
    };
    modules = [
      ./hosts/darwin/N4FQ62JR/configuration.nix
      inputs.home-manager.darwinModules.home-manager
      ({ inputs, stateVersion, ... }: {
        home-manager.extraSpecialArgs = {
          inherit inputs stateVersion;
        };
      })
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [
            inputs.darwin.overlays.default
            inputs.self.overlays.additions
            inputs.self.overlays.modifications
            inputs.self.overlays.unstable-packages
          ];
        }
      )
    ];
  };

}
