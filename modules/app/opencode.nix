{
  aegix.opencode.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.opencode ];

      # opencode re-fetches models.dev at runtime, which lacks the (unmerged) kiro
      # provider and overwrites the kiro models baked in at build time. Pin it to
      # the build-time data so the grafted kiro models stay visible.
      home.sessionVariables.OPENCODE_DISABLE_MODELS_FETCH = "true";
    };
}
