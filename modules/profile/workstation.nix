{ __findFile, ... }:
{
  # Linux-only by construction: a darwin machine is reached through its user,
  # not this profile.
  #
  # Deliberately absent: hardware (<aegix/audio>, <aegix/zsa>) stays with the
  # host that physically has it, <aegix/sops> is on every host regardless of
  # role, and the login shell is the user's choice.
  aegix.workstation = {
    includes = [
      <aegix/hyprland>
      <aegix/desktop-session>
      <aegix/file-chooser>
      <aegix/personal-network>
    ];
  };
}
