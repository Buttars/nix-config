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
        # Identity by path, for repos whose remote doesn't use the
        # github.com-buttars alias (e.g. the Obsidian vaults, committed by
        # the obsidian-git plugin via libgit2). Mirrors the jj --scope below.
        # Buttars account (github.com/Buttars, id 17345308):
        {
          condition = "gitdir:~/Projects/Personal/";
          contents.user = {
            name = "Buttars";
            email = "17345308+Buttars@users.noreply.github.com";
          };
        }
        {
          condition = "gitdir:~/Documents/Notes/Personal/";
          contents.user = {
            name = "Buttars";
            email = "17345308+Buttars@users.noreply.github.com";
          };
        }
        # landon-buttars-wgu account (github.com/landon-buttars-wgu, id 66702865):
        {
          condition = "gitdir:~/Documents/Notes/WGU/";
          contents.user = {
            name = "Landon Buttars";
            email = "66702865+landon-buttars-wgu@users.noreply.github.com";
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
      # includeIf. Use the personal identity for repos under these paths.
      "--scope" = [
        {
          "--when".repositories = [
            "~/Projects/Personal"
            "~/Documents/Notes/Personal"
          ];
          user = {
            name = "Buttars";
            email = "17345308+Buttars@users.noreply.github.com";
          };
        }
        {
          "--when".repositories = [ "~/Documents/Notes/WGU" ];
          user = {
            name = "Landon Buttars";
            email = "66702865+landon-buttars-wgu@users.noreply.github.com";
          };
        }
      ];
    };
  };
}
