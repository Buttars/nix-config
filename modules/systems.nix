{ den, __findFile, ... }:
{
  aegis = {
    workstation = den.lib.parametric.atLeast {
      includes = [
      ];
    };
    laptop = den.lib.parametric.atLeast {
      includes = [
        <aegis/workstation>
      ];
    };
    desktop = den.lib.parametric.atLeast {
      includes = [
        <aegis/workstation>
      ];
    };
    server = den.lib.parametric.atLeast {
      includes = [ ];
    };
  };
}
