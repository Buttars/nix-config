{
  aegix.jj = {
    homeManager =
      { ... }:
      {
        programs.jujutsu = {
          enable = true;
          settings.git.colocate = true;
        };
      };
  };
}
