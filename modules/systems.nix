{ __findFile, ... }:
{
  aegix = {
    laptop = {
      includes = [
        <aegix/workstation>
      ];
    };
    desktop = {
      includes = [
        <aegix/workstation>
      ];
    };
    server = {
      includes = [ ];
    };
  };
}
