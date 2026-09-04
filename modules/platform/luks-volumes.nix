{ ... }:
{
  aegix.luks-volumes.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.aegix.luks-volumes;

      # systemd escapes a dash in a path component as \x2d before turning the
      # separators into dashes, so /var/lib/private/open-webui is served by
      # var-lib-private-open\x2dwebui.mount.
      mountUnit =
        path:
        let
          stripped = lib.removeSuffix "/" (lib.removePrefix "/" path);
          dashed = lib.replaceStrings [ "-" ] [ "\\x2d" ] stripped;
        in
        "${lib.replaceStrings [ "/" ] [ "-" ] dashed}.mount";

      anyAutoLock = lib.any (v: v.autoLockMinutes > 0) (lib.attrValues cfg);
    in
    {
      options.aegix.luks-volumes = lib.mkOption {
        default = { };
        description = ''
          File-backed LUKS volumes that are unlocked by hand rather than at boot.
          `luks-create`, `luks-enroll`, `luks-unlock` and `luks-lock` operate on
          whatever is declared here, picking a volume with fzf when given no
          argument. Enrolling one shared passphrase across the volumes lets
          `luks-unlock --all` open them from a single prompt. Any unit named in
          `services` is bound to the mount so it cannot start without it.
        '';
        example = {
          vault = {
            mountPoint = "/var/lib/vault";
            size = "32G";
          };
        };
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, ... }:
            {
              options = {
                image = lib.mkOption {
                  type = lib.types.str;
                  default = "/var/lib/${name}.img";
                  description = "Backing file holding the LUKS container.";
                };

                mountPoint = lib.mkOption {
                  type = lib.types.str;
                  description = "Where the unlocked volume is mounted.";
                };

                fsType = lib.mkOption {
                  type = lib.types.str;
                  default = "ext4";
                  description = "Filesystem inside the container.";
                };

                size = lib.mkOption {
                  type = lib.types.str;
                  default = "16G";
                  description = ''
                    Size the create helper gives the backing file, unless it is
                    called with `--size`. Only read at creation time.
                  '';
                };

                services = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                  example = [ "open-webui" ];
                  description = ''
                    Units that must not run without the volume. They are unbound from
                    boot and started by `luks-unlock` instead, so they cannot write
                    to the mount point while it is still on the unencrypted parent.
                  '';
                };

                autoLockMinutes = lib.mkOption {
                  type = lib.types.int;
                  default = 15;
                  description = ''
                    Lock the volume again after this many minutes without any read
                    or write reaching its device. 0 leaves it unlocked until you
                    run `luks-lock`.
                  '';
                };
              };
            }
          )
        );
      };

      config = lib.mkIf (cfg != { }) {
        fileSystems = lib.mapAttrs' (
          name: v:
          lib.nameValuePair v.mountPoint {
            device = "/dev/mapper/${name}";
            inherit (v) fsType;
            options = [
              "noauto"
              "nofail"
            ];
          }
        ) cfg;

        systemd.services = lib.mkMerge (
          [
            (lib.mkIf anyAutoLock {
              luks-autolock = {
                description = "Lock idle LUKS volumes";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "/run/current-system/sw/bin/luks-autolock";
                };
              };
            })
          ]
          ++ lib.mapAttrsToList (
            _name: v:
            lib.genAttrs v.services (_: {
              wantedBy = lib.mkForce [ ];
              after = [ (mountUnit v.mountPoint) ];
              # BindsTo rather than Requires: it also stops the service when the
              # mount goes away on its own, not just when the unit is stopped.
              bindsTo = [ (mountUnit v.mountPoint) ];
            })
          ) cfg
        );

        systemd.timers.luks-autolock = lib.mkIf anyAutoLock {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "1min";
            OnUnitActiveSec = "1min";
          };
        };

        environment.systemPackages =
          let
            # Every declared volume becomes a case arm, so the commands stay in
            # sync with the config without anything being listed twice.
            meta = lib.concatMapStringsSep "\n" (name: ''
              ${name})
                image=${cfg.${name}.image}
                mount=${cfg.${name}.mountPoint}
                fstype=${cfg.${name}.fsType}
                size=${cfg.${name}.size}
                services=(${lib.concatStringsSep " " cfg.${name}.services})
                autolock=${toString cfg.${name}.autoLockMinutes}
                ;;'') (lib.attrNames cfg);

            preamble = ''
              volumes=(${lib.concatStringsSep " " (lib.attrNames cfg)})

              select_volume() {
                if [ "$#" -gt 0 ]; then
                  printf '%s' "$1"
                  return
                fi
                for v in "''${volumes[@]}"; do
                  if [ -e "/dev/mapper/$v" ]; then
                    printf '%s\t(unlocked)\n' "$v"
                  else
                    printf '%s\t(locked)\n' "$v"
                  fi
                done | fzf --delimiter='\t' --with-nth=1,2 --height=40% --prompt='volume> ' | cut -f1
              }

              load_meta() {
                case "$1" in
                  ${meta}
                  *) echo "unknown volume: $1" >&2; exit 1 ;;
                esac
              }

              resolve() {
                name=$(select_volume "$@")
                [ -n "$name" ] || exit 0
                load_meta "$name"
              }
            '';

            inputs = [
              pkgs.cryptsetup
              pkgs.e2fsprogs
              pkgs.util-linux
              pkgs.systemd
              pkgs.coreutils
              pkgs.gnused
              pkgs.fzf
            ];

            # The preamble is shared, so each command leaves some of the
            # variables it sets unused.
            exclusions = [ "SC2034" ];
          in
          [
            (pkgs.writeShellApplication {
              name = "luks-create";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              text = preamble + ''
                args=()
                while [ "$#" -gt 0 ]; do
                  case "$1" in
                    --size) size_override="$2"; shift 2 ;;
                    --size=*) size_override="''${1#--size=}"; shift ;;
                    -*) echo "usage: luks-create [--size SIZE] [volume]" >&2; exit 1 ;;
                    *) args+=("$1"); shift ;;
                  esac
                done

                resolve "''${args[@]}"
                size="''${size_override:-$size}"

                if [ -e "$image" ]; then
                  echo "$image already exists; refusing to overwrite it." >&2
                  exit 1
                fi
                echo "Creating $image at $size."
                truncate -s "$size" "$image"
                # btrfs copy-on-write over a loop-backed image fragments badly.
                chattr +C "$image" 2>/dev/null || true
                cryptsetup luksFormat "$image"
                cryptsetup open --type luks "$image" "$name"
                "mkfs.$fstype" "/dev/mapper/$name"
                cryptsetup close "$name"
                echo "Created $image. Unlock it with luks-unlock."
              '';
            })
            (pkgs.writeShellApplication {
              name = "luks-enroll";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              text = preamble + ''
                resolve "$@"
                if [ ! -e "$image" ]; then
                  echo "$image does not exist; create it with luks-create." >&2
                  exit 1
                fi
                # luksAddKey asks for any existing passphrase, then the new one.
                # Enrolling the same new passphrase on every volume is what lets
                # luks-unlock --all open them from a single prompt.
                cryptsetup luksAddKey "$image"
                echo "Added a key slot to $name."
              '';
            })
            (pkgs.writeShellApplication {
              name = "luks-unlock";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              text = preamble + ''
                mount_volume() {
                  mkdir -p "$mount"
                  mountpoint -q "$mount" || mount "/dev/mapper/$name" "$mount"
                  for s in "''${services[@]}"; do
                    systemctl start "$s.service"
                  done
                }

                if [ "''${1:-}" = "--all" ]; then
                  read -r -s -p "Passphrase: " passphrase
                  echo
                  status=0
                  for name in "''${volumes[@]}"; do
                    load_meta "$name"
                    if [ ! -e "/dev/mapper/$name" ]; then
                      if ! printf '%s' "$passphrase" |
                        cryptsetup open --type luks --key-file - "$image" "$name"; then
                        echo "could not unlock $name" >&2
                        status=1
                        continue
                      fi
                    fi
                    mount_volume
                  done
                  exit "$status"
                fi

                resolve "$@"
                if [ ! -e "/dev/mapper/$name" ]; then
                  cryptsetup open --type luks "$image" "$name"
                fi
                mount_volume
              '';
            })
            (pkgs.writeShellApplication {
              name = "luks-lock";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              text = preamble + ''
                resolve "$@"
                for s in "''${services[@]}"; do
                  systemctl stop "$s.service" || true
                done
                if mountpoint -q "$mount"; then
                  umount "$mount"
                fi
                if [ -e "/dev/mapper/$name" ]; then
                  cryptsetup close "$name"
                fi
              '';
            })
            (pkgs.writeShellApplication {
              name = "luks-migrate";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              text = preamble + ''
                resolve "$@"
                staging="$mount.premigrate"

                if mountpoint -q "$mount"; then
                  echo "$mount is mounted; run luks-lock first so the existing data is visible." >&2
                  exit 1
                fi
                if [ ! -e "$image" ]; then
                  echo "$image does not exist; create it with luks-create." >&2
                  exit 1
                fi
                if [ -e "$staging" ]; then
                  echo "$staging exists; finish or remove the previous migration first." >&2
                  exit 1
                fi
                if [ ! -d "$mount" ]; then
                  echo "nothing at $mount to migrate." >&2
                  exit 1
                fi

                for s in "''${services[@]}"; do
                  systemctl stop "$s.service" || true
                done

                mv "$mount" "$staging"
                if [ ! -e "/dev/mapper/$name" ]; then
                  cryptsetup open --type luks "$image" "$name"
                fi
                mkdir -p "$mount"
                mount "/dev/mapper/$name" "$mount"
                cp -aT "$staging" "$mount"

                for s in "''${services[@]}"; do
                  systemctl start "$s.service"
                done

                echo "Copied into $mount. The previous copy is still at $staging;"
                echo "remove it once you have confirmed the service is healthy."
              '';
            })
            (pkgs.writeShellApplication {
              name = "luks-autolock";
              runtimeInputs = inputs;
              excludeShellChecks = exclusions;
              # Idle is measured from the device's own io counters rather than
              # atime, which relatime only updates once a day, or open handles,
              # which a running service always holds.
              text = preamble + ''
                mkdir -p /run/luks-autolock
                now=$(date +%s)

                for name in "''${volumes[@]}"; do
                  [ -e "/dev/mapper/$name" ] || continue
                  load_meta "$name"
                  [ "$autolock" -gt 0 ] || continue

                  dev=$(basename "$(readlink -f "/dev/mapper/$name")")
                  counters=$(cat "/sys/class/block/$dev/stat" 2>/dev/null || true)
                  [ -n "$counters" ] || continue

                  state="/run/luks-autolock/$name"
                  if [ -f "$state" ] && [ "$(head -n1 "$state")" = "$counters" ]; then
                    since=$(sed -n 2p "$state")
                    if [ "$(( now - since ))" -ge "$(( autolock * 60 ))" ]; then
                      echo "locking $name after $autolock idle minutes"
                      # Sibling command in the same list, so it cannot be
                      # referenced by store path from here.
                      /run/current-system/sw/bin/luks-lock "$name"
                      rm -f "$state"
                    fi
                  else
                    printf '%s\n%s\n' "$counters" "$now" > "$state"
                  fi
                done
              '';
            })
          ];
      };
    };
}
