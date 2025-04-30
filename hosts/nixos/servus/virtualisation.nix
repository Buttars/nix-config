{
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /srv/services/docker 0755 root root -"
  ];
}
