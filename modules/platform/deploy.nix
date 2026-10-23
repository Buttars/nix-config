{
  aegix.deploy.nixos =
    { lib, ... }:
    {
      options.aegix.deploy = {
        targetHost = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
        };

        targetUser = lib.mkOption {
          type = lib.types.str;
          default = "root";
        };

        tags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
        };

        buildOnTarget = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
      };
    };
}
