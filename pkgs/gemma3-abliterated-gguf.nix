{
  lib,
  fetchurl,
  runCommand,
  gguf-pad-vocab,
}:
let
  repo = "huihui_ai/gemma3-abliterated";
  digest = "9bb38fbc0fa59a1c19a561a3afeeb2a62c6885be90e0aea31ade8db36cb7a856";

  src = fetchurl {
    url = "https://registry.ollama.ai/v2/${repo}/blobs/sha256:${digest}";
    hash = "sha256-m7OPvA+lmhwZpWGjr+6ypixohb6Q4K6jGt6Ns2y3qFY=";
    name = "gemma3-abliterated-4b-f16.gguf";
  };
in
runCommand "gemma3-abliterated-4b-gguf"
  {
    meta = {
      description = "huihui_ai/gemma3-abliterated 4B F16 with its tokenizer arrays padded to match token_embd.weight";
      license = lib.licenses.unfree;
      platforms = lib.platforms.all;
    };
  }
  ''
    ${lib.getExe gguf-pad-vocab} ${src} $out
  ''
