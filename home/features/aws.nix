{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awscli2
    terraform
    amazon-q-cli
  ];
}
