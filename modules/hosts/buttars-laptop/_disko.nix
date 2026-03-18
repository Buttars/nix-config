{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              passwordFile = "/tmp/secret.key";
              additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "/root".mountpoint = "/";
                  "/root".mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  "/home".mountpoint = "/home";
                  "/home".mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  "/nix".mountpoint = "/nix";
                  "/nix".mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                  "/swap".mountpoint = "/.swapvol";
                  "/swap".swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
