{
  aegis.wayland = {
    nixos =
      { pkgs, ... }:
      {
        programs.dconf.enable = true;
        environment.systemPackages = [ pkgs.wl-clipboard ];
        environment.sessionVariables = {
          NIXOS_OZONE_WL = "1";
        };
      };
    homeManager =
      { ... }:
      {
        qt.enable = true;
        gtk.enable = true;
      };
  };
}
