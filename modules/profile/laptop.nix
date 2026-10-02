{ __findFile, ... }:
{
  # A workstation that moves: same graphical session, plus the parts that only
  # matter when the wall socket is optional. Internal panels, bluetooth radios
  # and suspend-to-disk offsets are per-machine facts and stay with the host.
  aegix.laptop = {
    includes = [
      <aegix/workstation>
      <aegix/battery>
    ];
  };
}
