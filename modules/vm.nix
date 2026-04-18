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
      <aegix/wayland>
      <aegix/hyprland>
      <aegix/networking>
      (den._.tty-autologin "vm-user")
    ];

    nixos = {
      fileSystems."/".device = lib.mkDefault "/dev/noroot";
      fileSystems."/".fsType = lib.mkDefault "ext4";
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
      <aegix/devenv>
      <aegix/hyprland>
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
