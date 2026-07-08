{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.86.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_linux_amd64.tar.gz";
      hash = "sha256-COX1jPiVgDolTMHvUC9ds92OTIRsuCqciyY1ClqNccE=";
    };
    aarch64-linux = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_linux_arm64.tar.gz";
      hash = "sha256-Uho7FyBkU7fBy5tlpEYWsYjkQEc1wtiruhIy3vdwQo4=";
    };
    x86_64-darwin = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_darwin_amd64.tar.gz";
      hash = "sha256-fbat4G2//9zVZXVnnZ0hUoLSipWQHGqUbnjkAL7waG8=";
    };
    aarch64-darwin = {
      url = "https://github.com/marcus/sidecar/releases/download/v${version}/sidecar_${version}_darwin_arm64.tar.gz";
      hash = "sha256-2CMa1eFOtWqyWuaDaJwZ7FRJoD2LCVyA6BnxdJzQKeo=";
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
