{ __findFile, ... }:
{
  den.hosts.x86_64-linux.sentinel = {
    users.sentinel.classes = [ "home-manager" ];
  };
  den.aspects.sentinel = {
    includes = [
      <den/define-user>
      <aegis/networking>
      # (<aegis/disks/btrfs> {
      #   disk = "/dev/sda";
      #   withSwap = true;
      #   swapSize = "32";
      # })
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.cowsay ];
      };
  };
}
