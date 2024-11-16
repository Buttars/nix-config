{ nixpkgs, nixosModule, inputs, stateVersion, ... }:
let
  sys = system: mods: nixpkgs.lib.nixosSystem {
    inherit system;
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
    ] ++ mods;
    extraModules = [ ];
    specialArgs = { inherit inputs system; };
  };
  helper = import ../lib/helpers.nix { inherit inputs stateVersion; };
in
{
  vm = sys "x86_64-linux" [ ./nixos/vm ../hardware/vm/hardware-configuration.nix ];
  wsl = sys "x86_64-linux" [ ./nixos/vm ../hardware/wsl/hardware-configuration.nix];
  field-computer = sys "x86_64-linux" [ ./nixos/field-computer ];
  laptop = sys "x86_64-linux" [ ./nixos/laptop ];
  desktop = sys "x86_64-linux" [ ./nixos/desktop ];
  portainer = sys "x86_64-linux" [ ./nixos/portainer ];
  desktop-experimental = helper.mkNixos {
    hostname = "buttars-desktop";
    username = "buttars";
    modules = [./nixos/buttars-desktop];
  };
}

