{
  aegix.chatgpt.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.chatgpt ];
    };
}
