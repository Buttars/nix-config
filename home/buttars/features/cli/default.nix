{ lib, config, ... }:
{
  imports = [
    (lib.custom.relativeToRoot "home/features/cli/fish.nix")
    ./git.nix
    ./tmux.nix
  ];

  programs.starship.enable = true;

  programs.zoxide = {
    enable = true;
    enableFishIntegration = lib.mkIf config.programs.fish.enable true;
  };

}
