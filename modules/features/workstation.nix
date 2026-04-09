{ ... }:
{
  aegis.workstation = {
    homeManager =
      { ... }:
      {
        home.sessionVariables = {
          EDITOR = "nvim";
          TERMINAL = "kitty";
          BROWSER = "brave";
        };
      };
  };
}
