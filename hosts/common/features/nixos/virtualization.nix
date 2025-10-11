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
}
