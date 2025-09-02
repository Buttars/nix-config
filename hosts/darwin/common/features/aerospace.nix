{ pkgs, ... }:
let
  super = "alt";
in
{
  services.aerospace = {
    enable = true;
    package = pkgs.aerospace;

    settings = {
      # Root defaults
      default-root-container-layout = "tiles";
      default-root-container-orientation = "horizontal";

      # Make all windows tile (no floating) by default
      "on-window-detected" = [
        {
          "if".app-name-regex-substring = "kuandoHUB";
          run = [ "layout floating" ];
          check-further-callbacks = false;
        }
        {
          "if".app-name-regex-substring = "Microsoft Outlook";
          "if".window-title-regex-substring = "Reminder";
          run = [ "layout floating" ];
          check-further-callbacks = false;
        }
        {
          run = "layout tiling";
          check-further-callbacks = true;
        }
      ];

      exec = {
        inherit-env-vars = true;
      };


      "workspace-to-monitor-force-assignment" =
        builtins.listToAttrs
          (
            builtins.concatLists (
              builtins.genList
                (i:
                  [{
                    name = builtins.toString (i + 1);
                    value = builtins.genList (j: builtins.toString ((i + 1) * 10 + (j + 1))) 9;
                  }]
                )
                9
            )
          );

      mode.main.binding =
        let
          makeFocusCommand = direction: "focus --boundaries workspace --boundaries-action wrap-around-the-workspace ${direction}";
          makeSwapCommand = direction: "swap ${direction} --wrap-around";

          getFocusedWorkspace = ''
            aerospace list-workspaces --focused 2>/dev/null | head -1
          '';

          getActiveMonitorId = ''
            aerospace list-monitors --focused --format "%{monitor-id}" 2>/dev/null | head -1
          '';

          switchWorkspace = workspaceIndex: ''
            exec-and-forget bash -lc '
              monitorId=$(${getActiveMonitorId})
              targetWorkspace="''${monitorId}${toString workspaceIndex}"
              aerospace summon-workspace "$targetWorkspace"
            '
          '';

          moveWindowToWorkspace = workspaceIndex: ''
            exec-and-forget bash -lc '
              monitorId=$(${getActiveMonitorId})
              targetWorkspace="''${monitorId}${toString workspaceIndex}"
              aerospace move-node-to-workspace "$targetWorkspace"
            '
          '';
        in
        {
          # Launchers
          "${super}-enter" = ''exec-and-forget open -a "Kitty"'';
          "${super}-shift-q" = "exec-and-forget sysact";
          "${super}-w" = ''exec-and-forget open -a "Google Chrome"'';
          "${super}-r" = ''exec-and-forget open -a "Kitty" --args -e lfub'';
          "${super}-shift-r" = ''exec-and-forget open -a "Kitty" --args -e htop'';
          "${super}-n" = ''exec-and-forget open -a "Kitty" --args -e nvim -c VimwikiIndex'';
          "${super}-shift-s" = ''exec-and-forget bash -lc "screencapture -i -c"'';

          # Window focus (hjkl)
          # "${super}-h" = "focus left";
          # "${super}-j" = "focus down";
          # "${super}-k" = "focus up";
          # "${super}-l" = "focus right";
          # TODO: Unbind unused movement keys i.e. super-h and super-l
          "${super}-j" = makeFocusCommand "dfs-next";
          "${super}-k" = makeFocusCommand "dfs-prev";
          "${super}-shift-j" = makeSwapCommand "dfs-next";
          "${super}-shift-k" = makeSwapCommand "dfs-prev";



          # Window lifecycle
          "${super}-q" = "close";
          "${super}-f" = "fullscreen";
          # Disabling macos-native-fullscreen because it causes issues when separate spaces are disabled
          # It's buggy and doesn't always work as expected anyway
          # "${super}-shift-f" = "macos-native-fullscreen";

          # Monitor focus (wrap-around)
          "${super}-tab" = "focus-monitor --wrap-around right";
          "${super}-shift-tab" = "focus-monitor --wrap-around left";

          # TODO: Add monitor select mode
          "${super}-shift-left" = "focus-monitor --wrap-around left";
          "${super}-shift-right" = "focus-monitor --wrap-around right";

          # Move window to monitor
          "${super}-ctrl-j" = "move-node-to-monitor right";
          "${super}-ctrl-k" = "move-node-to-monitor left";

          # TODO: Add resize mode
          # Resize (arrow keys)
          "${super}-right" = "resize width +100";
          "${super}-left" = "resize width -100";
          "${super}-down" = "resize height +100";
          "${super}-up" = "resize height -100";

        } // builtins.foldl'
          (acc: s: acc // s)
          { }
          (builtins.genList
            (i: {
              "${super}-${toString (i + 1)}" = switchWorkspace (i + 1);
              "${super}-shift-${toString (i + 1)}" = [ (moveWindowToWorkspace (i + 1)) (switchWorkspace (i + 1)) ];
            }) 9);
    };
  };
}
