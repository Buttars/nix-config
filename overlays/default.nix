{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # fish 4.x (Rust rewrite) dropped create_manpage_completions.py, but many
    # nixpkgs packages still invoke it when generating fish completions. Stub it
    # back in so those builds succeed.
    fish = prev.fish.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
                mkdir -p $out/share/fish/tools
                cat > $out/share/fish/tools/create_manpage_completions.py <<'PYEOF'
        import sys
        # stub: fish 4.x removed this script; emit no completions
        PYEOF
      '';
    });

    # awscli2 =
    # if final.system == "aarch64-darwin" || final.system == "x86_64-darwin" then
    #   # inputs.nixpkgs-awscli2.legacyPackages.${final.system}.awscli2
    # else
    # prev.awscli2;

    direnv =
      if
        final.stdenv.hostPlatform.system == "aarch64-darwin"
        || final.stdenv.hostPlatform.system == "x86_64-darwin"
      then
        prev.direnv.overrideAttrs (old: {
          env = (old.env or { }) // {
            CGO_ENABLED = "1";
          };
        })
      else
        prev.direnv;

    # Kiro provider for opencode: graft the models.dev PR's Kiro provider TOMLs
    # onto the nixpkgs models-dev source (its deps build/cache cleanly, whereas
    # the PR branch's dev-based lockfile fails to bun-install aws-sdk). opencode
    # is re-injected with this models-dev below (it bakes the _api.json path).
    models-dev =
      let
        kiro = final.fetchFromGitHub {
          owner = "NachoFLizaur";
          repo = "models.dev";
          rev = "d46a74bd028291ff3a540c91ac43a5b8b9989633";
          hash = "sha256-6Hi7fr4oSvrSfXkcreywY7qpGC+DOEK9Dw9EnwBQhwM=";
        };
      in
      prev.models-dev.overrideAttrs (
        _finalAttrs: prevAttrs: {
          postPatch = (prevAttrs.postPatch or "") + ''
            cp -R ${kiro}/providers/kiro ./providers/kiro
          '';
        }
      );

    opencode =
      let
        src = final.fetchFromGitHub {
          owner = "NachoFLizaur";
          repo = "opencode";
          rev = "79efd6955801c412851faf2509b6f4718e71c911";
          hash = "sha256-fMTrraC2oFIT4C3s66z6lGaV89Cin8z/d8n2p6sJqFo=";
        };
      in
      (prev.opencode.override { inherit (final) models-dev; }).overrideAttrs (
        _finalAttrs: prevAttrs: {
          inherit src;
          passthru = prevAttrs.passthru // {
            node_modules = prevAttrs.passthru.node_modules.overrideAttrs (_: {
              inherit src;
              outputHash = "sha256-3xw5C4rxvsm/BJuFeaNLKwA4oBcADm4z1WK++Xvfkxc=";
            });
          };
        }
      );

    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  # unstable-packages = final: _prev: {
  #   unstable = import inputs.nixpkgs-unstable {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
}
