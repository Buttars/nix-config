{
  inputs,
  lib,
  ...
}:
let
  diskoConfigurations = {
    btrfs =
      {
        disk ? "/dev/vda",
        withSwap ? false,
        swapSize ? "8",
        ...
      }:
      {
        nixos.imports = [ inputs.disko.nixosModules.disko ];
        nixos.disko.devices = {
          disk = {
            disk0 = {
              type = "disk";
              device = disk;
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    priority = 1;
                    name = "ESP";
                    start = "1M";
                    end = "512M";
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "defaults" ];
                    };
                  };
                  root = {
                    size = "100%";
                    content = {
                      type = "btrfs";
                      extraArgs = [ "-f" ];
                      subvolumes = {
                        "@root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "@swap" = lib.mkIf withSwap {
                          mountpoint = "/.swapvol";
                          swap.swapfile.size = "${swapSize}G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };

  };
in
{
  flake-file.inputs.disko.url = "github:nix-community/disko";
  flake-file.inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  # flake.diskoConfigurations.btrfs = diskoConfigurations.btrfs;

  # USAGE:
  # den.aspects.my-server.includes = [
  #   (<aegis/disks/btrfs> {
  #     disk = "/dev/vda";
  #     withSwap = true;
  #     swapSize = "16";
  #   })
  # ];
  aegis.disks.provides.btrfs = diskoConfigurations.btrfs;
}
