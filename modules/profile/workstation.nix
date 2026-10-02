{ __findFile, ... }:
{
  # A graphical Linux machine I sit in front of.
  #
  # Linux-only by construction: every capability below is a Wayland session, a
  # display manager or a systemd service, none of which exist on darwin. A
  # darwin machine is reached through its user, not through this profile.
  #
  # Deliberately absent: hardware (<aegix/audio>, <aegix/zsa>) stays with the
  # host that physically has it, <aegix/sops> is on every host regardless of
  # role, and the login shell is the user's choice rather than the machine's.
  aegix.workstation = {
    includes = [
      <aegix/hyprland>
      <aegix/desktop-session>
      <aegix/file-chooser>
      <aegix/personal-network>
    ];
  };
}
