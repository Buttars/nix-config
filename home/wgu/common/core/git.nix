{ ... }: {
  imports = [
    ../../../common/core/git.nix
  ];

  programs.git = {
    enable = true;
    userName = "Landon Buttars";
    userEmail = "landon.buttars@wgu.edu";
  };
}
