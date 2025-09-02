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
          run = "layout tiling";
          check-further-callbacks = true;
        }
      ];

      exec = {
        inherit-env-vars = true;
      };

      mode.main.binding =
        let
          makeFocusCommand = direction: "focus --boundaries workspace --boundaries-action wrap-around-the-workspace ${direction}";
          makeSwapCommand = direction: "swap ${direction} --wrap-around";
        in
        {
          # Launchers
          "${super}-enter" = ''exec-and-forget open -a "Kitty"'';
          "${super}-shift-q" = "exec-and-forget sysact";
          # "${super}-w"     = ''exec-and-forget open -a "Google Chrome"'';
          "${super}-r" = ''exec-and-forget open -a "Kitty" --args -e lfub'';
          "${super}-shift-r" = ''exec-and-forget open -a "Kitty" --args -e htop'';
          "${super}-n" = ''exec-and-forget open -a "Kitty" --args -e nvim -c VimwikiIndex'';
          "${super}-shift-s" = ''exec-and-forget bash -lc "screencapture -i -c"'';

          # Window focus (hjkl)
          # "${super}-h" = "focus left";
          # "${super}-j" = "focus down";
          # "${super}-k" = "focus up";
          # "${super}-l" = "focus right";
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

          # Workspaces 1..9
          "${super}-1" = "workspace 1";
          "${super}-2" = "workspace 2";
          "${super}-3" = "workspace 3";
          "${super}-4" = "workspace 4";
          "${super}-5" = "workspace 5";
          "${super}-6" = "workspace 6";
          "${super}-7" = "workspace 7";
          "${super}-8" = "workspace 8";
          "${super}-9" = "workspace 9";

          # Move to workspace
          "${super}-shift-1" = "move-node-to-workspace 1";
          "${super}-shift-2" = "move-node-to-workspace 2";
          "${super}-shift-3" = "move-node-to-workspace 3";
          "${super}-shift-4" = "move-node-to-workspace 4";
          "${super}-shift-5" = "move-node-to-workspace 5";
          "${super}-shift-6" = "move-node-to-workspace 6";
          "${super}-shift-7" = "move-node-to-workspace 7";
          "${super}-shift-8" = "move-node-to-workspace 8";
          "${super}-shift-9" = "move-node-to-workspace 9";

          # Move window to monitor
          "${super}-ctrl-j" = "move-node-to-monitor right";
          "${super}-ctrl-k" = "move-node-to-monitor left";

          # TODO: Add resize mode
          # Resize (arrow keys)
          "${super}-right" = "resize width +100";
          "${super}-left" = "resize width -100";
          "${super}-down" = "resize height +100";
          "${super}-up" = "resize height -100";
        };
    };
  };
}
