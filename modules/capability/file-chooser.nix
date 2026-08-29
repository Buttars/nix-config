{ __findFile, ... }:
{
  # Which backend serves file dialogs. Swap the include for
  # <aegix/portal-termfilechooser> to pick files in yazi instead.
  aegix.file-chooser.includes = [
    <aegix/portal-gnome>
  ];
}
