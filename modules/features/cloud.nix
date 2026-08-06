{
  aegix.cloud.homeManager =
    { pkgs, ... }:
    {
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
      ];
    };
}
