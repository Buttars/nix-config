{
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.theatrum = { };
  den.aspects.theatrum = {
    includes = [
      <den/define-user>
      (<den/unfree> [ "nvidia-x11" ])
      <aegis/networking>
      # (<aegis/disks/btrfs> {
      #   disk = "/dev/sda";
      #   withSwap = true;
      #   swapSize = "32";
      # })
    ];

    nixos =
      { pkgs, config, ... }:
      {

        hardware.facter.reportPath = ./_facter.json;
        hardware.facter.detected.dhcp.interfaces = [ "ens18" ];

        fileSystems."/srv" =
          let
            nfsProvider = "truenas.lan";
            defaultNfsOptions = [
              "defaults"
              "noatime"
              "nfsvers=4.2"
              "rsize=262144"
              "wsize=262144"
              "nconnect=4"
              "async"
              "hard"
              "timeo=600"
              "retrans=2"
              "auto"
              "_netdev"
              "nofail"
            ];
          in
          {
            device = "${nfsProvider}:/mnt/veritas/cognito";
            fsType = "nfs";
            options = defaultNfsOptions;
          };

        services.jellyfin = {
          enable = true;
          dataDir = "/srv/services/jellyfin/data";
          configDir = "/srv/services/jellyfin/config";
        };

        virtualisation.podman.enable = true;

        networking = {
          defaultGateway = "10.0.40.1";
          nameservers = [ "10.0.40.1" ];
        };

        hardware.nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
          open = false;
        };

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            config.boot.kernelPackages.nvidiaPackages.stable
            nvidia-vaapi-driver
          ];
        };

        services.openssh.enable = true;
      };

    homeManager = { };
  };
}
