{ inputs, ... }:
{
  aegix.sops = {
    homeManager =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      let
        keyFile =
          if pkgs.stdenv.isDarwin then
            "${config.home.homeDirectory}/.config/sops/age/keys.txt"
          else
            "/var/lib/secrets/sops/age/keys.txt";
      in
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops = {
          defaultSopsFile = ./secrets.yaml;
          defaultSopsFormat = "yaml";
          age = {
            inherit keyFile;
            sshKeyPaths =
              if pkgs.stdenv.isDarwin then
                [ "${config.home.homeDirectory}/.ssh/id_ed25519" ]
              else
                [ "/etc/ssh/ssh_host_ed25519_key" ];
            generateKey = !pkgs.stdenv.isDarwin;
          };
        };
        home.sessionVariables.SOPS_AGE_KEY_FILE = keyFile;
        home.packages = [ pkgs.sops ];
      };
    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        defaultSopsFile = ./secrets.yaml;
        defaultSopsFormat = "yaml";
        age = {
          keyFile = "/var/lib/secrets/sops/age/keys.txt";
          sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          generateKey = true;
        };
      };
    };
  };

  flake-file.inputs = {
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
}
