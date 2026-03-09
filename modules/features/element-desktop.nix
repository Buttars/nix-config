{
  aegis.element-desktop.homeManager = { pkgs, ... }: {
    home.packages = with pkgs; [ element-desktop ];
  };
}
