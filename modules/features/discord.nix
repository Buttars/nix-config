{
  aegis.features._.discord.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        (discord.override {
          withVencord = true;
        })
      ];
    };
}
