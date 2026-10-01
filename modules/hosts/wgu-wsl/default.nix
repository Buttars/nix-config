{
  inputs,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.wgu-wsl = { };

  den.aspects.wgu-wsl = {
    includes = [
      <den/define-user>
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];

        wsl.enable = true;

        # modules/defaults.nix enables systemd-boot globally (srvos mixin), but
        # WSL has no bootloader at all -- Windows' own init hands control
        # straight to /init inside the distro image.
        boot.loader.systemd-boot.enable = lib.mkForce false;
      };
  };

  flake-file.inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  flake-file.inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
}
