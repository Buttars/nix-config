{ aegis, ... }:
{
  aegis.yazi = {
    homeManager =
      { ... }:
      {
        programs.yazi = {
          enable = true;
          shellWrapperName = "y";
          enableZshIntegration = true;
          enableFishIntegration = true;

          settings = {
            manager = {
              show_hidden = true;
              sort_by = "natural";
              sort_dir_first = true;
            };
          };

          keymap = {
            manager.prepend_keymap = [
              {
                on = [ "q" ];
                run = "quit";
                desc = "Quit";
              }
              {
                on = [ "<Esc>" ];
                run = "escape";
                desc = "Cancel";
              }
            ];
          };
        };
      };
  };
}
