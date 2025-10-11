{ ... }:
{
  programs.fish.shellAliases = {
    ll = "ls -la";
    dotfiles = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
    discord = "discord -enable-features=UseOzonePlatform -ozone-platform=wayland";
    ka = "killall";
    g = "git";
    sdn = "shutdown -h now";
    e = "$EDITOR";
    v = "$EDITOR";
    f = "fuck";
  };
}
