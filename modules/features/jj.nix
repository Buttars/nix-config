{
  aegix.jj = {
    homeManager =
      { ... }:
      {
        programs.jujutsu = {
          enable = true;
          settings = {
            git.colocate = true;
            ui.diff-editor = "vimdiff";
            merge-tools.vimdiff = {
              program = "nvim";
              diff-args = [
                "-d"
                "$left"
                "$right"
              ];
            };
          };
        };
      };
  };
}
