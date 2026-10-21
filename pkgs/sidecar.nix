{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "1.17.1";

  sources = {
    x86_64-linux = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_linux_amd64.tar.gz";
      hash = "sha256-8BItAOHpkerrSnVHiT2oBZMthTkyE7S+GA73F6I+oOg=";
    };
    aarch64-linux = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_linux_arm64.tar.gz";
      hash = "sha256-8fljDVLsAt9H/iX1/yHf6v++ZRK8Oqum5nTJj6hB+p4=";
    };
    x86_64-darwin = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_darwin_amd64.tar.gz";
      hash = "sha256-LL2wNK7+hvU2CbauQ2soQNdlSa6XuHkVA6q1RtkY4/g=";
    };
    aarch64-darwin = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_darwin_arm64.tar.gz";
      hash = "sha256-GN2nM0YKJgP/hQ4C5S8t7RsdWCbE45K4RmyAuPdvl68=";
    };
  };

  src = fetchurl sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "sidecar";
  inherit version src;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 sidecar $out/bin/sidecar
  '';

  meta = with lib; {
    description = "Use sidecar next to CLI agents for diffs, file trees, conversation history, and task management";
    homepage = "https://github.com/marcus/sidecar";
    license = licenses.mit;
    mainProgram = "sidecar";
    platforms = builtins.attrNames sources;
  };
}
