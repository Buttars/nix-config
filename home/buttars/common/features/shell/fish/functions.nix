{ ... }:
{
  programs.fish.interactiveShellInit = ''
    for command in mount umount sv su shutdown poweroff reboot
      function $command
        command sudo $command $argv
      end
    end

    function cp; command cp -iv $argv; end
    function mv; command mv -iv $argv; end
    function rm; command rm -vI $argv; end
    function bc; command bc -ql; end
    function rsync; command rsync -vrPlu $argv; end
    function mkd; command mkdir -pv $argv; end

    function ls; command ls -hN --color=auto --group-directories-first $argv; end
    function grep; command grep --color=auto $argv; end
    function diff; command diff --color=auto $argv; end
    function ccat; command highlight --out-format=ansi $argv; end
    function ip; command ip -color=auto $argv; end

    fish_vi_key_bindings
  '';
}
