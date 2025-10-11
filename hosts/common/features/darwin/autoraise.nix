{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    autoraise
  ];

  launchd.user.agents.autoraise = {
    command = "${pkgs.autoraise}/bin/autoraise";
    serviceConfig = {
      Program = "${pkgs.autoraise}/bin/autoraise";
      KeepAlive = true;
      RunAtLoad = true;
    };
  };
}
