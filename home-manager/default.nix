{ config, lib, pkgs, stateVersion, username, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory =
      if isDarwin then
        "/Users/${username}"
      else
        "/home/${username}";

    packages = with pkgs; [ ];

    services = {
      gpg-agent = lib.mkIf isLinux {
        enable = isLinux;
        enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };

    xdg = {
      enable = isLinux;
      userDirs = {
        # Do not create XDG directories for LIMA; it is confusing
        enable = isLinux;
        createDirectories = lib.mkDefault true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
        };
      };
    };
  };
}
