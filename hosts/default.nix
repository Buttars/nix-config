{ nixpkgs, nixosModule, inputs, outputs, wsl, xremap, superfile, ... } @ args:
let
  sys = system: mods: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      {
        _module.args = inputs;
        nixpkgs = {
          overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.unstable-packages
          ];
        };
      }
      nixosModule
      ../profiles/common.nix
      xremap
    ] ++ mods;
    extraModules = [ ];
    specialArgs = { inherit inputs system superfile; };
  };
in
{
  vm = sys "x86_64-linux" [ ./nixos/vm ../hardware/vm/hardware-configuration.nix ];
  wsl = sys "x86_64-linux" [ ./nixos/vm ../hardware/wsl/hardware-configuration.nix wsl ];
  field-computer = sys "x86_64-linux" [ ./nixos/field-computer ];
  laptop = sys "x86_64-linux" [ ./nixos/laptop ];
  desktop = sys "x86_64-linux" [ ./nixos/desktop ];
  portainer = sys "x86_64-linux" [ ./nixos/portainer ];
}

