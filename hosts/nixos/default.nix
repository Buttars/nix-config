{ inputs
, nixosModule
, stateVersion
, ...
}:
let
  helper = import ../../libs/helpers.nix { inherit inputs nixosModule stateVersion; };
  buttarsUser = 
  helper.mkUser {
    username = "buttars";
    authorizedKeyPath = ../nixos/common/users/buttars/keys/id_ed25519.pub;
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "postgres" "adbusers" ];
  };

in
{
  buttars-desktop = helper.mkNixos {
    hostname = "buttars-desktop";
    modules = [ 
      ./buttars-desktop 
      buttarsUser
    ];
  };

  buttars-laptop = helper.mkNixos {
    hostname = "buttars-laptop";
    modules = [ 
      ./buttars-laptop 
      buttarsUser
    ];
  };

  servus = helper.mkNixos {
    hostname = "servus";
    username = "servus";
    modules = [ 
      ./servus 
      (helper.mkUser {
        username = "servus";
        authorizedKeyPath = ../nixos/common/users/buttars/keys/id_ed25519.pub;
        extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "postgres" "adbusers" ];
      })
    ];
  };

  theatrum = helper.mkNixos {
    hostname = "theatrum";
    username = "theatrum";
    modules = [ 
      ./theatrum 
      (helper.mkUser {
        username = "theatrum";
        authorizedKeyPath = ../nixos/common/users/buttars/keys/id_ed25519.pub;
        extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "postgres" "adbusers" ];
      })
    ];
  };
}
