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

          interactiveShellInit = ''
            # Bash-style !! (last command) and !$ (last arg)
            function __fish_last_command
              commandline -i (history --max=1)
            end
            function __fish_last_arg
              set -l last (history --max=1)
              commandline -i (string split ' ' -- $last)[-1]
            end
            bind ! __fish_last_command
            bind '$' __fish_last_arg
          '';
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
              gwt = "git-worktree-init";
              ns = "tv nix-search-tv";
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
