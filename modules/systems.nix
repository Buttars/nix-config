{ den, __findFile, ... }:
{
  aegix = {
    workstation = den.lib.parametric.atLeast {
      includes = [
      ];
    };
    laptop = den.lib.parametric.atLeast {
      includes = [
        <aegix/workstation>
      ];
    };
    desktop = den.lib.parametric.atLeast {
      includes = [
        <aegix/workstation>
      ];
    };
    server = den.lib.parametric.atLeast {
      includes = [ ];
    };
  };
}
