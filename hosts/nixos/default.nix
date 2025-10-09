{ inputs
, nixosModule
, stateVersion
, ...
}:
let
  helper = import ../../libs/helpers.nix { inherit inputs nixosModule stateVersion; };
in
{
  buttars-desktop = helper.mkNixos {
    hostname = "buttars-desktop";
    modules = [ 
      ./buttars-desktop 
      (helper.mkUser {
        username = "buttars";
        authorizedKeyPath = ../nixos/common/users/buttars/keys/id_ed25519.pub;
        extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "postgres" "adbusers" ];
      })
    ];
  };

  buttars-laptop = helper.mkNixos {
    hostname = "buttars-laptop";
    modules = [ ./buttars-laptop ];
  };

  servus = helper.mkNixos {
    hostname = "servus";
    username = "servus";
    modules = [ ./servus ];
  };

  theatrum = helper.mkNixos {
    hostname = "theatrum";
    username = "theatrum";
    modules = [ ./theatrum ];
  };
}
