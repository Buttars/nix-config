{ config, lib, pkgs, ... }:
let
  cfg = config.host.profiles.virtualization;
in
{
  options.host.profiles.virtualization = {
    enable = lib.mkEnableOption "Enable virtualization profile";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      virt-manager
      qemu
      looking-glass-client
    ];
  };
}
