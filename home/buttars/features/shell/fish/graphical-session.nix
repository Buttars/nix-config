{ ... }:
{
  programs.fish.interactiveShellInit = ''
    if test (tty) = "/dev/tty1"
      if type -q Hyprland
        if not pgrep -x Hyprland > /dev/null
          exec Hyprland
        end
      end
    end
  '';
}
