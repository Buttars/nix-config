{
  runCommand,
  python3,
}:
let
  python = python3.withPackages (ps: [
    ps.gguf
    ps.numpy
    ps.tqdm
  ]);
in
runCommand "gguf-pad-vocab"
  {
    meta.mainProgram = "gguf-pad-vocab";
  }
  ''
    mkdir -p $out/bin
    substitute ${./gguf-pad-vocab.py} $out/bin/gguf-pad-vocab \
      --replace-fail "@python@" "${python}/bin/python3"
    chmod +x $out/bin/gguf-pad-vocab
  ''
