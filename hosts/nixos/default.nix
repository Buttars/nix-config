{ inputs, nixosModule, stateVersion, ... }: let 
  helper = import ../../libs/helpers.nix { inherit inputs nixosModule stateVersion; };
in {
  buttars-desktop = helper.mkNixos {
    hostname = "buttars-desktop";
    modules = [ ./buttars-desktop ];
  };
}
