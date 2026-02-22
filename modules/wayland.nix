{
  aegis.wayland = {
    nixos =
      { pkgs, lib, ... }:
      {
        programs.dconf.enable = true;
        environment.systemPackages = [ pkgs.wl-clipboard ];
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };
      };
    homeManager =
      { config, ... }:
      {
        qt.enable = true;
        gtk.enable = true;
      };
  };
}
