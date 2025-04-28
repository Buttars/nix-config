{ ... }:
let
  nfsProvider = "10.0.0.5";
  defaultNfsOptions = [ "defaults" "noatime" "nfsvers=4" "hard" "timeo=600" "auto" "_netdev" "nofail" ];
in
{
  fileSystems."/srv/services" = {
    device = "${nfsProvider}:/mnt/veritas/cognito/services";
    fsType = "nfs";
    options = defaultNfsOptions;
  };

  fileSystems."/srv/media" = {
    device = "${nfsProvider}:/mnt/veritas/cognito/media";
    fsType = "nfs";
    options = defaultNfsOptions;
  };

  fileSystems."/srv/frigate" = {
    device = "${nfsProvider}:/mnt/veritas/cognito/frigate";
    fsType = "nfs";
    options = defaultNfsOptions;
  };

}
