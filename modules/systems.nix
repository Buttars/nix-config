{ __findFile, ... }:
{
  aegix = {
    workstation = {
      includes = [
      ];
    };
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
