{
  aegis.nfs-utils.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [ nfs-utils ];
    };
}
