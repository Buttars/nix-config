{
  aegix.password-manager = {
    _.keepassxc.homeManager =
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
