{ nixpkgs, nixosModule, inputs, nixos-wsl, ... } @ args:

let
  sys = system: mods: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [{ _module.args = inputs; } nixosModule] ++ mods;
    extraModules = [];
    specialArgs = { inherit inputs; };
  };
in
{
  vm = sys "x86_64-linux" [ ./vm ../hardware/vm/hardware-configuration.nix ];
  wsl = sys "x86_64-linux" [ ./vm ../hardware/wsl/hardware-configuration.nix nixos-wsl.nixosModules.wsl ];
  field-computer = sys "x86_64-linux" [ ./field-computer ];
  laptop = sys "x86_64-linux" [ ./laptop ];
  desktop = sys "x86_64-linux" [ ./desktop ];
}

