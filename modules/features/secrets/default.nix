{ inputs, ... }:
let
  config = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
in
{
  aegis.secrets = {
    nixos = {
        imports = [
          inputs.sops-nix.nixosModules.sops
        ];
        sops = config;
      };

    homeManager = { pkgs, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ]; 
      sops = config;
      home.sessionVariables.SOPS_AGE_KEY_FILE = config.age.keyFile;
      home.packages = [ pkgs.sops ];
    };
  };
}
