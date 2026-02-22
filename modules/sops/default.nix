{ inputs, ... }:
let
  sops_config = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";
    age = {
      keyFile = "/var/lib/secrets/sops/age/keys.txt";
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      generateKey = true;
    };
  };
in
{
  aegis.secrets = {
    homeManager =
      { pkgs, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops = sops_config;
        home.sessionVariables.SOPS_AGE_KEY_FILE = sops_config.age.keyFile;
        home.packages = [ pkgs.sops ];
      };
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = sops_config;
    };
  };

  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
