{ aegix, ... }:
{
  aegix.yazi = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.ouch ];

        programs.yazi = {
          enable = true;
          shellWrapperName = "y";
          enableZshIntegration = true;
          enableFishIntegration = true;

          settings = {
            mgr = {
              show_hidden = true;
              sort_by = "natural";
              sort_dir_first = true;
            };
          };

          keymap = {
            mgr.prepend_keymap = [
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
              {
                on = [ "X" ];
                run = "shell -- ouch decompress --yes %s";
                desc = "Extract archive here";
              }
              {
                on = [ "T" ];
                run = "shell \"ouch compress %s \" --interactive";
                desc = "Compress selection into an archive";
              }
            ];
          };
        };
      };
  };
}
