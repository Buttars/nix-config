{ inputs, ... }: {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "/home/buttars/.config/sops/age/keys.txt";

    defaultSopsFile = ../../../secrets.yaml;
    validateSopsFiles = false;

    secrets = {
      "private_keys/buttars" = {
        path = "/home/buttars/.ssh/id_ed25519";
      };
    };
  };

}
