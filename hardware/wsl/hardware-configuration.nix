{ config, lib, pkgs, modulesPath, ... }: let
in {
  imports = [];

  wsl.enable = true;
  wsl.defaultUser = "nixos";

}
