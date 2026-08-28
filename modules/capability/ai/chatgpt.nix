{
  aegix.ai._.chatgpt.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.chatgpt ];
    };
}
