{
  aegix.cloud.homeManager =
    { pkgs, lib, ... }:
    {
      programs.granted = {
        enable = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
      };

      home.packages = with pkgs; [
        # AWS
        awscli2
        aws-vault
        ssm-session-manager-plugin

        # Kubernetes
        (lib.hiPrio kubectl) # take priority over minikube's bundled kubectl
        minikube
        kubernetes-helm
        k9s
        kubectx
        stern

        # Terraform
        terraform
        tflint
        pre-commit
        just

        # Pulumi
        pulumi-bin
        pulumi-esc
      ];
    };
}
