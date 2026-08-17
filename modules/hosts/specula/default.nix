{
  inputs,
  __findFile,
  ...
}:
{
  den.hosts.aarch64-linux.specula = {
    users.specula = {
      classes = [ "homeManager" ];
    };
  };

  den.aspects.specula = {
    includes = [
      <den/define-user>
      <aegix/sops>
      <aegix/reticulum>
    ];

    nixos =
      {
        config,
        pkgs,
        lib,
        modulesPath,
        ...
      }:
      {
        imports = [
          inputs.nixos-hardware.nixosModules.raspberry-pi-3
          "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
        ];

        # No official nixos-hardware profile exists for the Pi Zero 2 W; it
        # shares the BCM2837 SoC with the Pi 3, so the Pi 3 profile is reused.
        nixpkgs.hostPlatform = "aarch64-linux";

        # modules/default.nix enables systemd-boot globally (srvos mixin), but
        # RPi boots via the firmware bootloader + generic-extlinux-compatible,
        # which the raspberry-pi-3 profile already enables.
        boot.loader.systemd-boot.enable = lib.mkForce false;

        services.openssh.enable = true;

        systemd.tmpfiles.rules = [
          # A pre-generated host key baked into the image, so sops-nix can
          # derive its age key and decrypt secrets (incl. wifi creds) on
          # first boot. An SD image has no network-install step to register
          # a freshly-generated key's age pubkey before the device is live.
          "C /etc/ssh/ssh_host_ed25519_key 0600 root root - ${./host_key/ssh_host_ed25519_key}"
          "C /etc/ssh/ssh_host_ed25519_key.pub 0644 root root - ${./host_key/ssh_host_ed25519_key.pub}"
          # Seeded once; edit /var/lib/reticulum/config by hand afterward,
          # per <aegix/reticulum>'s convention, then `systemctl restart reticulum`.
          "C /var/lib/reticulum/config 0640 reticulum reticulum - ${./reticulum-config}"
        ];

        sops.secrets.buttars-password.neededForUsers = true;
        sops.secrets.specula-wifi-psk = { };
        sops.templates."specula-wifi.nmconnection" = {
          path = "/etc/NetworkManager/system-connections/specula-wifi.nmconnection";
          owner = "root";
          mode = "0600";
          content = ''
            [connection]
            id=specula-wifi
            type=wifi
            autoconnect=true

            [wifi]
            mode=infrastructure
            ssid=CHANGEME-ssid

            [wifi-security]
            key-mgmt=wpa-psk
            psk=${config.sops.placeholder.specula-wifi-psk}

            [ipv4]
            method=auto

            [ipv6]
            method=auto
          '';
        };

        networking.networkmanager.enable = true;

        users.mutableUsers = false;
        users.users.specula.hashedPasswordFile = config.sops.secrets.buttars-password.path;
        users.users.specula.extraGroups = [
          "wheel"
          "networkmanager"
        ];
        users.users.specula.openssh.authorizedKeys.keyFiles = [
          ../../users/buttars/keys/id_ed25519.pub
        ];

        # RNode LoRa board connects over USB serial.
        users.users.reticulum.extraGroups = [ "dialout" ];
        environment.systemPackages = [ pkgs.nomadnet ];
      };

    homeManager =
      { lib, ... }:
      {
        # <aegix/devenv> (global default) enables direnv, which drags fish
        # into the closure for its test suite -- fish's tests are flaky
        # under QEMU emulation (ulimit/noshebang behave differently) and
        # specula has no interactive dev-shell use for direnv anyway.
        programs.direnv.enable = lib.mkForce false;
      };
  };

  flake-file.inputs.nixos-hardware.url = "github:NixOS/nixos-hardware";
}
