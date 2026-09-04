{
  aegix.ollama.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      ai = import ../lib/_ai-models.nix;

      registryModels = lib.filterAttrs (_: m: !(m.local or false)) ai.models;

      # ollama's own go template for huihui_ai/gemma3-abliterated, kept verbatim so
      # the locally created copy behaves exactly like the registry one.
      gemma3Modelfile = pkgs.writeText "gemma3-abliterated.Modelfile" ''
        FROM ${pkgs.gemma3-abliterated-gguf}
        TEMPLATE """{{- range $i, $_ := .Messages }}
        {{- $last := eq (len (slice $.Messages $i)) 1 }}
        {{- if or (eq .Role "user") (eq .Role "system") }}<start_of_turn>user
        {{ .Content }}<end_of_turn>
        {{ if $last }}<start_of_turn>model
        {{ end }}
        {{- else if eq .Role "assistant" }}<start_of_turn>model
        {{ .Content }}{{ if not $last }}<end_of_turn>
        {{ end }}
        {{- end }}
        {{- end }}"""
        PARAMETER stop <end_of_turn>
        PARAMETER temperature 1
        PARAMETER top_k 64
        PARAMETER top_p 0.95
      '';
    in
    {
      services.ollama = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        enable = true;
        package = pkgs.ollama-vulkan;
        host = "0.0.0.0";
        port = 11434;
        openFirewall = true;
        loadModels = builtins.attrNames registryModels;
        environmentVariables.OLLAMA_CONTEXT_LENGTH = toString ai.models.${ai.default}.contextLength;
      };

      systemd.services.ollama-local-models = lib.mkIf config.services.ollama.enable {
        description = "Register locally built ollama models";
        wantedBy = [ "multi-user.target" ];
        after = [ "ollama.service" ];
        bindsTo = [ "ollama.service" ];
        environment = config.systemd.services.ollama.environment;
        serviceConfig = {
          Type = "oneshot";
          DynamicUser = true;
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";
        };
        script = ''
          ${lib.getExe config.services.ollama.package} create gemma3-abliterated:4b -f ${gemma3Modelfile}
        '';
      };
    };
}
