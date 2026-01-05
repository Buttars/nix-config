{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  cfg = config.programs.npm;
in
{
  options.programs.npm = {
    enable = mkEnableOption "npm";

    enableXdgSupport = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Configures NPM to respect XDG_Base_Directory standard.

        Environment:
          NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc

        npmrc:
          prefix=''${XDG_DATA_HOME}/npm
          cache=''${XDG_CACHE_HOME}/npm
          init-module=''${XDG_CONFIG_HOME}/npm/config/npm-init.js
          logs-dir=''${XDG_STATE_HOME}/npm/logs
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = ''
        Arbitrary npm settings written as key=value lines.

        Example:
          programs.npm.settings = {
            "registry"    = "https://registry.npmjs.org/";
            "save-prefix" = "^";
            "audit"       = "false";
          };
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        # Example:
        # @my-scope:registry=https://npm.mycompany.internal/
        # always-auth=true
      '';
      description = "Extra literal .npmrc lines appended at the end.";
    };
  };

  config =
    let
      npmrc =
        let
          settingsLines = lib.mapAttrsToList (name: value: "${name}=${value}") cfg.settings;

          blocks = lib.filter (s: s != "") [
            (lib.concatStringsSep "\n" settingsLines)
            cfg.extraConfig
          ];
        in
        lib.concatStringsSep "\n" blocks + "\n";
    in
    mkIf cfg.enable {
      home.sessionVariables = lib.mkIf cfg.enableXdgSupport {
        NPM_CONFIG_USERCONFIG = "$XDG_CONFIG_HOME/npm/npmrc";
      };

      home.file = lib.mkIf (!cfg.enableXdgSupport) {
        ".npmrc".text = npmrc;
      };

      xdg.configFile = lib.mkIf cfg.enableXdgSupport {
        "npm/npmrc".text = npmrc;
      };
    };
}
