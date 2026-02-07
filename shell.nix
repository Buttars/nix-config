{
  pkgs,
  ...
}:
{
  default = {
    #   env.NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    #   packages = with pkgs; [
    #     nix
    #     home-manager
    #     git
    #     just
    #
    #     sops
    #     ssh-to-age
    #     gnupg
    #     age
    #   ];
  };
}
