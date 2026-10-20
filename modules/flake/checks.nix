{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      checks.module-layers = pkgs.runCommand "check-module-layers" { } ''
        ${pkgs.bash}/bin/bash ${./check-layers.sh} ${inputs.self} | tee "$out"
      '';

      # `nix flake check` only visits the current system, so on darwin it would
      # pass while every NixOS host is broken. Forcing each toplevel drvPath
      # here evaluates all of them from whichever system runs the check; the
      # context is discarded so they are evaluated, never built.
      checks.hosts-evaluate =
        let
          configs = inputs.self.nixosConfigurations // inputs.self.darwinConfigurations;
          line =
            name: cfg:
            "${name} ${builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath}";
        in
        pkgs.writeText "check-hosts-evaluate" (
          lib.concatStringsSep "\n" (lib.mapAttrsToList line configs) + "\n"
        );
    };
}
