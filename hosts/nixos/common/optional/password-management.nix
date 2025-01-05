{ pkgs, ... }:
{
  # TODO: Make this declarative when we can manage secrets.
  environment.systemPackages = with pkgs; [
    syncthing
    keepassxc
    keepmenu
  ];
}
