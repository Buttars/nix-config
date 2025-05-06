{ ... }: {
  programs.git = {
    enable = true;
    delta.enable = true;
    lfs.enable = true;
    extraConfig = {
      log.decorate = "short";
      log.abbrevCommit = "true";
      log.format = "oneline";
      format.pretty = "oneline";
      push.autoSetupRemote = true;
    };
  };
}
