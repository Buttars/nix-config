{ pkgs, ... }:
{
  hostConfig = {
    modules = {
      zsh.enable = true;
      alacritty.enable = false;
      brave.enable = true;
      discord.enable = true;
      obsidian.enable = true;
      docker.enable = true;
      steam.enable = true;
      vdhcoapp.enable = true;
      starship.enable = true;
      fastfetch.enable = true;
      xremap.enable = true;
      spr.enable = true;
      zoxide.enable = true;
      nvidia.enable = true;
    };

    profiles = {
      hyprland.enable = true;
      audio.enable = true;
      password-management.enable = true;
      programming.enable = true;
      syncthing.enable = true;
      tui-file-manager.enable = true;
      tui-task-manager.enable = true;
      virtualization.enable = true;
      zsa.enable = true;
    };
  };

  programs.nix-ld.enable = true;

  imports = [
    ./users
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "buttars-laptop";
  };

  networking.networkmanager.dispatcherScripts = [
    {
      # https://wiki.archlinux.org/title/NetworkManager#Dynamically_set_NTP_servers_received_via_DHCP_with_systemd-timesyncd
      # You can debug with sudo journalctl -u NetworkManager-dispatcher -e
      # make sure to restart NM as described above
      source = pkgs.writeText "10-update-timesyncd" ''
        [ -z "$CONNECTION_UUID" ] && exit 0
        INTERFACE="$1"
        ACTION="$2"
        case $ACTION in
        up | dhcp4-change | dhcp6-change)
            systemctl restart systemd-timesyncd.service
            if [ -n "$DHCP4_NTP_SERVERS" ]; then
              echo "Will add the ntp server $DHCP4_NTP_SERVERS"
            else
              echo "No DHCP4 NTP available."
              exit 0
            fi
            mkdir -p /etc/systemd/timesyncd.conf.d
            # <<-EOF must really use tabs to keep indentation correct… and tabs are often converted to space in wiki
            # so I don't want to risk strange issues with indentation
            echo "[Time]" > "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            echo "NTP=$DHCP4_NTP_SERVERS" >> "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            systemctl restart systemd-timesyncd.service
            ;;
        down)
            rm -f "/etc/systemd/timesyncd.conf.d/''${CONNECTION_UUID}.conf"
            systemctl restart systemd-timesyncd.service
            ;;
        esac
        echo 'Done!'
      '';
    }
  ];

  # services.ntp.enable = true;
  services.automatic-timezoned.enable = true;
  services.timesyncd.enable = true;

  time.timeZone = "America/Denver";


  system.stateVersion = "22.05";
}

