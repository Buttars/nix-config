{ ... }:
let
  nfsProvider = "10.0.0.5";
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
