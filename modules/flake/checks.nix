{ inputs, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks.module-layers = pkgs.runCommand "check-module-layers" { } ''
        ${pkgs.bash}/bin/bash ${./check-layers.sh} ${inputs.self} | tee "$out"
      '';
    };
}
