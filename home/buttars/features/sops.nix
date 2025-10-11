{ inputs, config, ... }:
{
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
      "openai_api_key" = { };
    };

    templates = {
      "neovim-avante.env" = {
        content = ''
          set -gx OPENAI_API_KEY ${config.sops.placeholder.openai_api_key}
        '';
      };

    };
  };

}
