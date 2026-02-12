{
  features.aws = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          awscli2
          terraform
        ];
      };
  };
}
