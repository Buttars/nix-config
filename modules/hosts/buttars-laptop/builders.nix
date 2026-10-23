{
  den.aspects.buttars-laptop.nixos =
    { config, ... }:
    {
      aegix.attic.push = true;

      sops.secrets.builder-key = {
        key = "private_keys/buttars";
        path = "/root/.ssh/id_ed25519";
        mode = "0600";
      };
      systemd.tmpfiles.rules = [ "d /root/.ssh 0700 root root -" ];

      nix.distributedBuilds = true;

      nix.settings.builders-use-substitutes = true;

      nix.buildMachines = [
        {
          hostName = "buttars-desktop.lan";
          sshUser = "root";
          sshKey = config.sops.secrets.builder-key.path;
          protocol = "ssh-ng";
          systems = [
            "x86_64-linux"
            "aarch64-linux"
          ];
          maxJobs = 16;
          speedFactor = 2;
          supportedFeatures = [
            "big-parallel"
            "kvm"
            "nixos-test"
            "benchmark"
          ];
        }
      ];

      programs.ssh.knownHosts."buttars-desktop.lan".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINbvJ2OnaXRekIu32USJDkcAsKyvlJGNnhQ8wZbkxCsc";
    };
}
