{
  flake-file.inputs.dotfiles = {
    url = "https://github.com/Buttars/.dotfiles";
    type = "git";
    ref = "main";
    rev = "a52773c370f6837c666292e24adbbffe43a61de1";
    submodules = false;
    flake = false;
    # allRefs = true;
  };
}
