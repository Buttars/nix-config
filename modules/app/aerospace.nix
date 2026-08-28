{ pkgs, ... }:
let
  super = "alt";
in
{
  aegix.aerospace = {
    homeManager = {
      programs.aerospace = {
        enable = true;
        package = pkgs.aerospace;
        launchd.enable = true;

        settings = {
          default-root-container-layout = "tiles";
          default-root-container-orientation = "horizontal";

          exec.inherit-env-vars = true;

          gaps = {
            inner.vertical = 10;
            inner.horizontal = 10;
            outer.left = 10;
            outer.bottom = 10;
            outer.top = 10;
            outer.right = 10;
          };

          on-window-detected = [
            {
              "if".app-name-regex-substring = "Microsoft Outlook";
              "if".window-title-regex-substring = "Reminder";
              run = [ "layout floating" ];
              check-further-callbacks = false;
            }
            {
              "if".app-name-regex-substring = "Microsoft Outlook";
              "if".window-title-regex-substring = "^$";
              run = [ "layout floating" ];
              check-further-callbacks = false;
            }
            {
              "if".app-id = "com.apple.finder";
              run = [ "layout floating" ];
              check-further-callbacks = false;
            }
            {
              "if".app-name-regex-substring = "(CalendarAgent|kuandoHUB|Cisco Secure Client)";
              run = [ "layout floating" ];
              check-further-callbacks = false;
            }
            {
              run = "layout tiling";
              check-further-callbacks = true;
            }
          ];

          workspace-to-monitor-force-assignment = builtins.listToAttrs (
            builtins.concatLists (
              builtins.genList (
                i:
                builtins.genList (j: {
                  name = builtins.toString (((i + 1) * 10) + (j + 1));
                  value = builtins.toString (i + 1);
                }) 9
              ) 9
            )
          );

          mode.main.binding =
            let
              makeFocusCommand =
                direction:
                "focus --boundaries workspace --boundaries-action wrap-around-the-workspace ${direction} --ignore-floating";
              makeSwapCommand = direction: "swap ${direction} --wrap-around";
              makeMoveNodeToMonitorCommand =
                direction: "move-node-to-monitor ${direction} --wrap-around --focus-follows-window";
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
                aerospace summon-workspace "$targetWorkspace"
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

              # Window focus
              "${super}-j" = makeFocusCommand "dfs-next";
              "${super}-k" = makeFocusCommand "dfs-prev";
              "${super}-shift-j" = makeSwapCommand "dfs-next";
              "${super}-shift-k" = makeSwapCommand "dfs-prev";

              # Window lifecycle
              "${super}-q" = "close";
              "${super}-f" = "fullscreen";
              "${super}-space" = "layout floating tiling";

              # Monitor focus
              "${super}-tab" = "focus-monitor --wrap-around right";
              "${super}-shift-tab" = "focus-monitor --wrap-around left";
              "${super}-shift-left" = "focus-monitor --wrap-around left";
              "${super}-shift-right" = "focus-monitor --wrap-around right";

              # Move window to monitor
              "${super}-ctrl-j" = makeMoveNodeToMonitorCommand "next";
              "${super}-ctrl-k" = makeMoveNodeToMonitorCommand "prev";

              # Resize
              "${super}-right" = "resize width +100";
              "${super}-left" = "resize width -100";
              "${super}-down" = "resize height +100";
              "${super}-up" = "resize height -100";
            }
            // builtins.foldl' (acc: s: acc // s) { } (
              builtins.genList (i: {
                "${super}-${toString (i + 1)}" = switchWorkspace (i + 1);
                "${super}-shift-${toString (i + 1)}" = moveWindowToWorkspace (i + 1);
              }) 9
            );
        };
      };
    };
  };
}
