{
  aegix.fish = {
    nixos = {
      programs.fish = {
        enable = true;
        vendor = {
          completions.enable = true;
          config.enable = true;
          functions.enable = true;
        };
      };
    };

    homeManager =
      { pkgs, ... }:
      {
        programs.fish = {
          enable = true;

          shellInit = ''
            set fish_greeting
          '';

          loginShellInit = "";
          interactiveShellInit = "";
          shellInitLast = "";
        };
      };

    _.aliases = {
      homeManager =
        { lib, pkgs, ... }:
        {
          programs.fish = {
            shellAliases = {
              ll = "ls -la";
              ka = "killall";
              g = "git";
              e = "$EDITOR";
              v = "$EDITOR";
            }
            // lib.optionalAttrs pkgs.stdenv.isLinux {
              sdn = "shutdown -h now";
            };

            interactiveShellInit = ''
              function cp; command cp -iv $argv; end
              function mv; command mv -iv $argv; end
              function rm; command rm -vI $argv; end
              function rsync; command rsync -vrPlu $argv; end

              function define_sudo_wrappers --argument-names commands
                for cmd in $commands
                  set -l def "
                  function $cmd
                      command sudo -- $cmd \$argv
                  end"
                  eval $def
                end
              end

              define_sudo_wrappers mount umount shutdown reboot sv su

              fish_vi_key_bindings
            '';
          };
        };
    };
  };
}
