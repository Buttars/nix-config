{ __findFile, ... }:
{
  # A workstation that never moves. Nothing distinguishes it from
  # <aegix/workstation> at the role level -- the difference is what `laptop`
  # adds, not what `desktop` does -- so this name exists to say "mains-powered,
  # fixed displays" at a host's include site rather than to carry config.
  aegix.desktop = {
    includes = [
      <aegix/workstation>
    ];
  };
}
