{
  inputs,
  __findFile,
  ...
}:
{
  den.hosts.x86_64-linux.wgu-wsl = {
    users.wgu-wsl = {
      classes = [ "homeManager" ];
    };
  };

  den.aspects.wgu-wsl = {
    # Dropped `programming` (atac/compose2nix/devpod/lazydocker) and `cli`
    # (intelli-shell/television/wikiman/eza/btop) -- interactive niceties a
    # scripting jump box has no use for. `git`/`jj` stay: VCS is what's scripted.
    includes = [
      <den/define-user>
      <aegix/git>
      <aegix/jj>
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ inputs.nixos-wsl.nixosModules.default ];

        wsl.enable = true;
        wsl.defaultUser = "wgu-wsl";

        # modules/defaults.nix enables systemd-boot globally (srvos mixin), but
        # WSL has no bootloader at all -- Windows' own init hands control
        # straight to /init inside the distro image.
        boot.loader.systemd-boot.enable = lib.mkForce false;

        users.users.wgu-wsl.extraGroups = [ "wheel" ];
        users.users.wgu-wsl.openssh.authorizedKeys.keyFiles = [
          ../../users/buttars/keys/id_ed25519.pub
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          jq
          ripgrep
          fd
          unzip
        ];
      };
  };

  flake-file.inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
  flake-file.inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
}
