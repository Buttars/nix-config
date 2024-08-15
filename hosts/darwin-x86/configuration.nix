{ pkgs, dotfiles, ... }:
{

  imports = [
    ./system.nix
    ../../profiles/programming.nix
    ../../profiles/terminal-gui.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    neovim
    fd
    gotop
    sshfs
    fuse
    nettools
    cargo
    #libgcc
    gnumake
    unzip
    ripgrep
    luajitPackages.luarocks-nix
  ];

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
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  # nixpkgs.hostPlatform = "x86_64-darwin";
}
