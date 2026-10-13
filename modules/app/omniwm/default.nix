{
  aegix.omniwm.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    # Guard rather than rely on the module: its platform assertion hard-fails on
    # linux, and this aspect is included from a user aspect that may evaluate there.
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      programs.omniwm = {
        enable = true;
        # OmniWM rewrites this from its GUI; Nix owns it, so mirror GUI changes back.
        settings = ./settings.toml;
      };
    };
}
