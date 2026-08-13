{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.0.2";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/kaushiksrini/parqeye/releases/download/v${version}/parqeye-aarch64-apple-darwin.tar.xz";
      hash = "sha256-GZW1nwa1cgxGvrK82toIx8Vovw0BsYLXoeUMf9wwW5o=";
      dir = "parqeye-aarch64-apple-darwin";
    };
    x86_64-linux = {
      url = "https://github.com/kaushiksrini/parqeye/releases/download/v${version}/parqeye-x86_64-unknown-linux-gnu.tar.xz";
      hash = "sha256-qtUf3HejZeJE9kAceEIsWt5NiSUhCkjH1lbL8us/jnE=";
      dir = "parqeye-x86_64-unknown-linux-gnu";
    };
  };

  source = sources.${stdenv.hostPlatform.system};
  src = fetchurl { inherit (source) url hash; };
in
stdenv.mkDerivation {
  pname = "parqeye";
  inherit version src;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 ${source.dir}/parqeye $out/bin/parqeye
  '';

  meta = with lib; {
    description = "Peek inside Parquet files right from your terminal";
    homepage = "https://github.com/kaushiksrini/parqeye";
    license = licenses.mit;
    mainProgram = "parqeye";
    platforms = builtins.attrNames sources;
  };
}
