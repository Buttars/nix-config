{ nixpkgs, nixosModule, inputs, ... }@args:

let
  sys = system: mods: nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [{ _module.args = inputs; } nixosModule] ++ mods;
    extraModules = [];
    specialArgs = { inherit inputs; };
  };
in
{
  vm = sys "x86_64-linux" [ ./vm ];
  field-computer = sys "x86_64-linux" [ ./field-computer ];
}

