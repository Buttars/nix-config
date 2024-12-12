{ nixpkgs, nixosModule, inputs, stateVersion, ... }:
let
  helper = import ../lib/helpers.nix { inherit inputs nixosModule stateVersion; };
in
{
  wsl = helper.mkNixos {
    hostname = "vm";
    username = "vm";
    modules = [ ./nixos/vm ];
  };
  field-computer = helper.mkNixos {
    hostname = "field-computer";
    username = "field-computer";
    modules = [ ./nixos/field-computer ];
  };
  laptop = helper.mkNixos {
    hostname = "laptop";
    username = "buttars";
    modules = [ ./nixos/laptop ];
  };
  portainer = helper.mkNixos {
    hostname = "portainer";
    username = "portainer";
    modules = [ ./nixos/portainer-servus ];
  };
  desktop = helper.mkNixos {
    hostname = "buttars-desktop";
    username = "buttars";
    modules = [./nixos/desktop];
  };
  karaoke = helper.mkNixos {
    hostname = "karaoke";
    platform = "aarch64-linux";
    username = "karaoke";
    modules = [
      {
        nixpkgs.buildPlatform = "x86_64-linux";
        nixpkgs.hostPlatform = "aarch64-linux";
      }
      ./nixos/karaoke
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    ];
  };
}

