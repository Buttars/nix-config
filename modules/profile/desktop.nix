{ __findFile, ... }:
{
  # Intentionally carries no config: the name exists to mark "mains-powered,
  # fixed displays" at a host's include site.
  aegix.desktop = {
    includes = [
      <aegix/workstation>
    ];
  };
}
