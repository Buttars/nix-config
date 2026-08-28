{
  aegix.keepassxc.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ keepassxc ];
    };
}
