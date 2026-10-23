{
  aegix.github-runner.nixos =
    {
      config,
      pkgs,
      ...
    }:
    let
      home = "/var/lib/github-runner";
    in
    {
      users.users.github-runner = {
        isSystemUser = true;
        group = "github-runner";
        inherit home;
      };
      users.groups.github-runner = { };

      systemd.tmpfiles.rules = [
        "d ${home} 0750 github-runner github-runner -"
        "d ${home}/.ssh 0700 github-runner github-runner -"
      ];

      sops.secrets.github-runner-token.owner = "github-runner";
      sops.secrets."private_keys/deploy" = {
        owner = "github-runner";
        path = "${home}/.ssh/id_ed25519";
        mode = "0600";
      };

      programs.ssh.knownHosts = {
        "torrens.lan".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPrh0+1amL/9qVTxU2zb04dpczSwtNIG6L8vaipdY3qX";
        "theatrum.lan".publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILSIwl/OjpOde85046V8vub0AhmYgQJXE8MLAJ6+Z/jM";
      };

      services.github-runners.nix-config = {
        enable = true;
        url = "https://github.com/Buttars/nix-config";
        tokenFile = config.sops.secrets.github-runner-token.path;
        user = "github-runner";
        group = "github-runner";
        replace = true;
        ephemeral = true;
        extraLabels = [ "nix-config" ];
        extraPackages = [
          pkgs.colmena
          pkgs.git
          pkgs.openssh
        ];
        extraEnvironment.HOME = home;
      };
    };
}
