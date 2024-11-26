{ config, hostname, username, inputs, lib, pkgs, platform, stateVersion, ... }: {
  imports = [
    ./${hostname}
    ../../profiles/common.nix
  ];

  boot = {
    # consoleLogLevel = lib.mkDefault 0;
    initrd.verbose = false;
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [ "udev.log_priority=3" ];
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.consoleMode = "max";
      systemd-boot.enable = true;
      systemd-boot.memtest86.enable = true;
      timeout = 10;
    };
  };

  documentation.enable = true;
  documentation.nixos.enable = false;
  documentation.man.enable = true;
  documentation.info.enable = false;
  documentation.doc.enable = false;

  environment = {
    defaultPackages =
      with pkgs;
      lib.mkForce [
        coreutils-full
        micro
      ];

    variables = {
      EDITOR = "nvim";
      SYSTEMD_EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "${platform}";
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];

    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = lib.mkDefault "flakes nix-command";
        flake-registry = "";
        nix-path = config.nix.nixPath;
        trusted-users = [
          "root"
          "buttars"
          "${username}" # TODO: Find way to make this multi-user compatible
        ];
        warn-dirty = false;
      };
      channel.enable = false;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged
        # programs here, NOT in environment.systemPackages
      ];
    };
  };

  services = { };

  system = {
    inherit stateVersion;
  };

}
