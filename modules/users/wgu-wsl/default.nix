{ den, __findFile, ... }:
{
  den.aspects.wgu-wsl-user = {
    includes = [
      <den/primary-user>
      <aegix/git>
      <aegix/jj>
    ];

    nixos = {
      wsl.defaultUser = "landon.buttars";

      users.users."landon.buttars".extraGroups = [ "wheel" ];
      users.users."landon.buttars".openssh.authorizedKeys.keyFiles = [
        ../landon-buttars/keys/id_ed25519.pub
      ];

      nix.settings.trusted-users = [ "landon.buttars" ];
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          jq
          ripgrep
          fd
          unzip
        ];
      };
  };

  den.hosts.x86_64-linux.wgu-wsl.users."landon.buttars" = {
    classes = [ "homeManager" ];
    aspect = den.aspects."wgu-wsl-user";
  };
}
