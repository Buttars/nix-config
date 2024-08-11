{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    taskwarrior3
  ];
}
