{ __findFile, ... }:
{
  # Get from power-on to a usable graphical session: a splash instead of kernel
  # log, a greeter that lists the installed sessions, the services a session
  # assumes exist, and fonts to draw any of it with.
  aegix.desktop-session.includes = [
    <aegix/plymouth>
    <aegix/greeter>
    <aegix/desktop-services>
    <aegix/fonts>
  ];
}
