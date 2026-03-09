{
  aegis.virtualization = {
    _.docker = {
      virtualisation.docker = {
        enable = true;
      };
    };
    _.libvirtd.nixos =
      { pkgs, ... }:
      {
        virtualisation.libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
          };
        };

        environment.systemPackages = with pkgs; [
          virt-manager
          qemu
          looking-glass-client
        ];
      };
  };
}
