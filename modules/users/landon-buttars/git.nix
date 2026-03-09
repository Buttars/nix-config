{ den, ... }:
{
  den.aspects."landon.buttars".homeManager = {
    programs.git = {
      enable = true;
      userName = "Landon Buttars";
      userEmail = "landon.buttars@wgu.edu";

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
  };
}
