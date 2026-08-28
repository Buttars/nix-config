{
  aegix.cloud.homeManager =
    { pkgs, ... }:
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
        minikube # bundles kubectl
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
