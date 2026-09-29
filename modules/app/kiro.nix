{
  aegix.kiro.homeManager =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.kiro-cli ];

      # cli.json is app-writable, so merge in the default-agent setting at
      # activation rather than managing the file read-only.
      home.activation.kiroDefaultAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        cfg="$HOME/.kiro/settings/cli.json"
        if [ -e "$cfg" ]; then
          ${pkgs.jq}/bin/jq '."chat.defaultAgent" = "default"' "$cfg" \
            | $DRY_RUN_CMD ${pkgs.moreutils}/bin/sponge "$cfg"
        fi
      '';

      home.file.".kiro/settings/mcp.json".text = builtins.toJSON {
        mcpServers = import ./ai/_mcp.nix { inherit pkgs config; };
      };

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
