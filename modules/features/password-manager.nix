{
  features.password-manager = {
    _.keepassxc.homeManger =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ keepassxc ];
      };
    _.bitwarden.homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          bitwarden-cli
          bitwarden-desktop
        ];
      };
  };
}
