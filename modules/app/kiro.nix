{
  aegix.kiro.homeManager =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.kiro-cli ];

      # cli.json is app-writable, so merge settings in at activation rather than
      # managing the file read-only.
      #
      # Without disableInheritingDefaultResources, Kiro injects all of
      # ~/.kiro/steering into every agent and the per-agent `rules` lists in
      # _agents.nix have no effect.
      home.activation.kiroCliSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="$HOME/.kiro/settings/cli.json"
        if [ -e "$cfg" ]; then
          ${pkgs.jq}/bin/jq '
            ."chat.defaultAgent" = "default"
            | ."chat.disableInheritingDefaultResources" = true
          ' "$cfg" \
            | $DRY_RUN_CMD ${pkgs.moreutils}/bin/sponge "$cfg"
        fi
      '';

      programs.zsh.shellAliases.kc = "kiro-cli chat";

      programs.fish.shellAliases.kc = "kiro-cli chat";

      programs.zsh.initContent = lib.mkMerge [
        (lib.mkBefore ''
          eval "$(kiro-cli init zsh pre)"
        '')
        (lib.mkAfter ''
          eval "$(kiro-cli init zsh post)"
        '')
      ];

      programs.fish.interactiveShellInit = lib.mkMerge [
        (lib.mkBefore ''
          kiro-cli init fish pre | source
        '')
        (lib.mkAfter ''
          kiro-cli init fish post | source
        '')
      ];
    };
}
