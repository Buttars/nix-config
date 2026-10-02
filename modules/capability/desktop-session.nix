{ __findFile, ... }:
{
  aegix.desktop-session.includes = [
    <aegix/plymouth>
    <aegix/greeter>
    <aegix/desktop-services>
    <aegix/fonts>
  ];
}
