{
  inputs,
  nixosModule,
  stateVersion,
  ...
}:
{
  mkHome =
    {
      hostname,
      username ? "buttars",
      platform ? "x86_64-linux",
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          platform
          username
          stateVersion
          ;
      };
      modules = [ ../home-manager ];
    };

  mkUser =
    {
      username,
      homeFile ? null,
      extraGroups ? [ "wheel" ],
      shellPkg ? null,
      authorizedKeyPath ? ./keys/id_ed25519.pub,
    }:
    {
      inputs,
      pkgs,
      lib,
      config,
      stateVersion,
      ...
    }:
    let
      ifGroupsExist = groups: builtins.filter (g: builtins.hasAttr g config.users.groups) groups;

      rel = lib.custom.relativeToRoot;

      resolvedHomeFile =
        if homeFile != null then homeFile else rel "home/${username}/${config.networking.hostName}.nix";

      resolvedShell = if shellPkg != null then shellPkg else pkgs.fish;
    in
    {
      users.users.${username} = {
        isNormalUser = true;
        shell = resolvedShell;
        extraGroups = lib.flatten [ (ifGroupsExist extraGroups) ];
        openssh.authorizedKeys.keys = [ (builtins.readFile authorizedKeyPath) ];
      };

      home-manager = {
        useGlobalPkgs = true;
        backupFileExtension = "backup";
        extraSpecialArgs = { inherit inputs stateVersion; };
        users.${username} = import resolvedHomeFile;
      };
    };

  mkNixos =
    {
      hostname,
      username ? "buttars",
      platform ? "x86_64-linux",
      modules ? [ ],
      systemConfiguration ? inputs.nixpkgs.lib.nixosSystem,
    }:
    systemConfiguration {
      modules = [
        {
          _module.args = inputs;
        }
        nixosModule
        ../hosts/common/core/nixos
        { networking.hostName = hostname; }
      ]
      ++ modules;
      specialArgs = {
        inherit
          inputs
          platform
          stateVersion
          ;

        lib = inputs.nixpkgs.lib.extend (
          self: super: { custom = import ../libs { inherit (inputs.nixpkgs) lib; }; }
        );
      };
    };
}
