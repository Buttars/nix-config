# Slicer for 3D printing. OrcaSlicer ships Creality printer profiles
# (Ender/CR/K1 series) and can send sliced files straight to the printer
# over the network (Moonraker/Klipper- and Creality OS-compatible upload).
{
  aegix.printing3d.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.orca-slicer ];
    };
}
