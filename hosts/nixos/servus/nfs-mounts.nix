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
  fileSystems."/srv" = {
    device = "${nfsProvider}:/mnt/veritas/cognito";
    fsType = "nfs";
    options = defaultNfsOptions;
  };
}
