{ inputs, ... }:
{
  flake-file.inputs = {
    paneru.url = "github:karinushka/paneru";
    paneru.inputs.nixpkgs.follows = "nixpkgs";
  };

  aegix.paneru = {
    homeManager = {
      imports = [ inputs.paneru.homeModules.paneru ];
      services.paneru = {
        enable = true;
        settings = {
          options = {
            focus_follows_mouse = true;
            mouse_follows_focus = true;
          };
          bindings = {
            window_focus_west = "cmd - h";
            window_focus_east = "cmd - l";
            window_focus_north = "cmd - k";
            window_focus_south = "cmd - j";
            window_swap_west = "alt - h";
            window_swap_east = "alt - l";
            window_center = "alt - c";
            window_resize = "alt - r";
            window_fullwidth = "alt - f";
            window_manage = "ctrl + alt - t";
            quit = "ctrl + alt - q";
          };
        };
      };
    };
  };
}
