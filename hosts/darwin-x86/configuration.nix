{ pkgs, dotfiles, ... }:
{

  imports = [
    ./system.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    #libgcc
    bat
    cargo
    delta
    devenv
    devpod
    fd
    fuse
    gcc
    git
    gnumake
    go
    gotop
    lazydocker
    luajitPackages.luarocks-nix
    neovim
    nettools
    nixpkgs-fmt
    nodejs
    python3
    ripgrep
    sshfs
    tmux
    unzip
  ];

  programs.direnv.enable = true;

  users.users."landon.buttars" = {
    home = "/Users/landon.buttars";
  };

  home-manager.users."landon.buttars" = import ./home.nix { inherit pkgs dotfiles; };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 5;

  # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "x86_64-darwin";
}
