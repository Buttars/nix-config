{
  aegix.locale.nixos =
    { lib, ... }:
    {
      i18n = {
        defaultLocale = lib.mkDefault "en_US.UTF-8";
        supportedLocales = lib.mkDefault [
          "en_US.UTF-8/UTF-8"
        ];
      };
      time.timeZone = lib.mkDefault "America/Denver";
    };

  aegix.locale.homeManager = {
    home.sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
  };
}
