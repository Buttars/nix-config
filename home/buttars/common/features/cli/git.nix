{ ... }: {
  imports = [
    ../../../../common/core/git.nix
  ];

  programs.git = {
    enable = true;
    userName = "Landon Buttars";
    userEmail = "17345308+Buttars@users.noreply.github.com";
  };
}
