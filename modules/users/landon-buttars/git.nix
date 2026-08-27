{ den, ... }:
{
  den.aspects."landon.buttars".homeManager = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Landon Buttars";
        email = "landon.buttars@wgu.edu";
      };

      includes = [
        {
          condition = "hasconfig:remote.*.url:git@github.com-buttars:*/**";
          contents.user = {
            name = "Landon Buttars";
            email = "17345308+Buttars@users.noreply.github.com";
          };
        }
      ];
    };
    programs.jujutsu.settings = {
      user = {
        name = "Landon Buttars";
        email = "landon.buttars@wgu.edu";
      };

      # jj (0.44) only supports path-based conditions, not git's remote-based
      # includeIf. Use the personal identity for repos under ~/Projects/Personal.
      "--scope" = [
        {
          "--when".repositories = [ "~/Projects/Personal" ];
          user.email = "17345308+Buttars@users.noreply.github.com";
        }
      ];
    };
  };
}
