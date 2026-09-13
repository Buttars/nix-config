{
  # Any user may reboot without authenticating. systemd's default policy asks
  # for admin auth when the session has no seat, which is every ssh session --
  # so `ssh host systemctl reboot` prompts for a password it cannot read.
  aegix.reboot.nixos = {
    security.polkit.enable = true;
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.login1.reboot" ||
            action.id == "org.freedesktop.login1.reboot-multiple-sessions") {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
