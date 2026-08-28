# specula: Remaining Work

Raspberry Pi Zero 2 W running a portable Reticulum node. Base config lives in
`modules/hosts/specula/`; see that directory's `default.nix` for what's
already wired up (host key bootstrap, sops, wifi via NetworkManager,
`<aegix/reticulum>` + `nomadnet`).

## Wifi: home AP -> mesh-only

Currently configured to join a normal wifi AP (NetworkManager +
`specula-wifi-psk` sops secret), so the device is reachable for setup and
day-to-day management. The eventual goal is **RNode + mesh wifi only** — no
dependency on a fixed home AP.

- [ ] Decide the concrete mesh-wifi mechanism (e.g. 802.11s ad-hoc mode,
      batman-adv, or just pointing Reticulum's `AutoInterface` at an existing
      mesh AP) — this determines whether NetworkManager stays in the picture
      at all or gets replaced with `networking.wireless`/`wpa_supplicant` in
      ad-hoc mode.
- [ ] Once decided, replace the `specula-wifi.nmconnection` sops template in
      `modules/hosts/specula/default.nix` with the mesh config.
- [ ] Re-evaluate whether the pre-baked host SSH key / sops bootstrap is still
      needed once wifi no longer depends on a secret PSK (it may still be
      useful for other secrets, but the original justification — decrypting a
      wifi password before the device has network — goes away).

## Before first flash

- [ ] Set the real SSID: replace `ssid=CHANGEME-ssid` in
      `modules/hosts/specula/default.nix` (`sops.templates."specula-wifi.nmconnection"`).
- [ ] Set the real wifi password:
      `sops modules/app/sops/secrets.yaml` and replace the `specula-wifi-psk`
      placeholder (`CHANGEME-wifi-password`).
- [ ] Build the image:
      `nix build --impure .#nixosConfigurations.specula.config.system.build.sdImage`
      (needs `boot.binfmt.emulatedSystems = [ "aarch64-linux" ]`, already
      enabled on buttars-desktop).
- [ ] `dd` the resulting `.img.zst` (decompress first, or `zstdcat img.zst | dd of=/dev/sdX bs=4M status=progress`)
      to the SD card.

## RNode / LoRa

`modules/hosts/specula/reticulum-config` seeds only the `AutoInterface`
(wifi/IP). The `RNodeInterface` block is present but commented out —
frequency/power/spreading-factor are region- and board-specific and weren't
guessed.

- [ ] Get the RNode hardware, flash RNode firmware
      (`rnodeconf --autoinstall`, installed system-wide via `<aegix/reticulum>`).
- [ ] Probe it (`rnodeconf --info /dev/ttyUSB0`) and fill in the real
      frequency/bandwidth/txpower/spreadingfactor/codingrate in
      `reticulum-config`, matching local ISM-band regulations.
- [ ] Uncomment the `[[RNode LoRa Interface]]` block, `systemctl restart reticulum`.
- [ ] Confirm `/dev/ttyUSB0` is the right device path — if it's not stable
      across reboots/reconnects, add a udev rule for a fixed symlink instead
      of hardcoding `ttyUSB0`.

## Reticulum config choices to revisit

- [ ] `enable_transport = True` is set in `reticulum-config`, meaning specula
      will relay traffic for others, not just act as an endpoint. That's a
      reasonable default for a node meant to extend the mesh, but worth
      confirming — flip to `False` if you want it client-only.
- [ ] `nomadnet` is installed but unconfigured — run it once via SSH
      (`nomadnet`) to create an LXMF identity and set a display name.

## Build via GitHub Actions instead of local emulation

Local builds under `boot.binfmt.emulatedSystems` work but are slow (QEMU
emulation) and tie up buttars-desktop. Plan: move the sdImage build to a
GitHub Actions workflow using a native arm64 runner instead.

- [ ] Add `.github/workflows/specula-image.yml`, `workflow_dispatch` trigger
      (manual — this costs money per run, don't run it on every push).
- [ ] `runs-on: ubuntu-24.04-arm` — GitHub's hosted arm64 runner (native, no
      emulation needed).
- [ ] Install Nix via `DeterminateSystems/nix-installer-action` (check for
      current version tag at build time).
- [ ] `nix build --impure .#nixosConfigurations.specula.config.system.build.sdImage`,
      then `actions/upload-artifact` the resulting `.img.zst`.
- [ ] No secrets needed in CI — `sops.templates`/`config.sops.placeholder`
      values are only resolved at _runtime_ on the device via sops-nix's
      activation script, not at build time. The image build never touches
      age keys.
- [ ] **Needs a build cache.** This repo applies custom overlays
      (`self.overlays.additions`/`modifications`), which changes derivation
      hashes and defeats most of cache.nixos.org's prebuilt aarch64-linux
      binaries — so without a cache, most of the closure (including the
      kernel) rebuilds from source on every run. Set up either: - Cachix (free tier for small/personal use), or - nixbuild.net's cache, or - `actions/cache` keyed on the derivation, though this is clunkier for
      Nix than a proper binary cache.
      Push to the cache from the workflow so repeat builds are fast/cheap.
- [ ] Cost ballpark from initial research: 2-core Linux arm64 hosted runner
      is $0.005/min; free entirely on a public repo, or 2,000 free min/month
      on a private repo's Free plan before billing kicks in. A from-scratch
      build (no cache yet) could run $1-5; with a working cache, repeat
      builds should be much cheaper/faster.

## After first boot

- [ ] SSH in as `specula` (buttars' key is preloaded), confirm
      `systemctl status reticulum` is active and `rnstatus` shows the
      AutoInterface up.
- [ ] Confirm sops secrets decrypted correctly (`ls /run/secrets/`) — if the
      device won't decrypt, the baked host key likely didn't take; check
      `journalctl -u sops-nix` on first boot.
