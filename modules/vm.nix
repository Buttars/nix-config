{
  inputs,
  den,
  __findFile,
  lib,
  ...
}:
{

  den.aspects.vm = {
    includes = [
      (den._.tty-autologin "vm-user")
    ];

    nixos = {
      fileSystems."/".device = lib.mkDefault "/dev/noroot";
      boot.loader.grub.enable = lib.mkDefault false;
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.neovim ];
      };
  };

  den.aspects.vm-user = {
    includes = [
      <den/primary-user>
      <aegis/devenv>
      (den._.user-shell "fish")
    ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.btop ];
      };
  };

  den.hosts.x86_64-linux.vm.users.vm-user = { };

  perSystem =
    { pkgs, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            host = inputs.self.nixosConfigurations.vm.config;
          in
          ''
            ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
          '';
      };
    };
}
