{
  shared.aws.home-manager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        terraform
      ];
    };
}
