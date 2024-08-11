{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    git
    delta
    ripgrep
  ];
}
