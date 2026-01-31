{
  shared.git = {
    programs.git.enable = true;

    home-manager =
      { pkgs, ... }:
      {
        base = {
          programs.git = {
            enable = true;
            lfs.enable = true;
            settings = {
              log.decorate = "short";
              log.abbrevCommit = "true";
              log.format = "oneline";
              format.pretty = "oneline";
              push.autoSetupRemote = true;
              pull.rebase = true;
            };
          };
        };
        lfs = {
          programs.git.lfs.enable = true;
        };
        delta = {
          programs.delta.enable = true;
          programs.delta.enableGitIntegration = true;
        };
        diffnav = {
          home.packages = [ pkgs.diffnav ];
          programs.git.settings.core.pager.diff = "diffnav";
        };
      };
  };
}
