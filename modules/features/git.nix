{
  aegis.features._.git = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          delta
          diffnav
        ];
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
            core.pager = "delta";
            pager.diff = "diffnav";
          };
        };
      };
  };
}
