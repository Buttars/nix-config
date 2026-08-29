{
  # file-roller is GUI only; without these, `unzip foo.zip` is a missing command.
  aegix.archive-tools.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        unzip
        zip
        p7zip
        xz
      ];
    };
}
