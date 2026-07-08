{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.51.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_linux_amd64.tar.gz";
      hash = "sha256-//HqJ9Emmd3Jm6KeXiHEZKDnjtsvVX33ReUtE2QbHaU=";
    };
    aarch64-linux = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_linux_arm64.tar.gz";
      hash = "sha256-nDy4isyNgO9ZRI2DlQT7TD9ukYkZ134rK5mOPgpjZXw=";
    };
    x86_64-darwin = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_darwin_amd64.tar.gz";
      hash = "sha256-m7dVQWrJJaimpFdi7qr0OXHn8WIK3wZ8772PU8h3CfE=";
    };
    aarch64-darwin = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_darwin_arm64.tar.gz";
      hash = "sha256-wJsKTIQDmYK3m6LTAB1BItBdyOV9hbfN6crIQ9iU3Kk=";
    };
  };

  src = fetchurl sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "td";
  inherit version src;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 td $out/bin/td
  '';

  meta = with lib; {
    description = "A minimalist CLI for tracking tasks across AI coding sessions";
    homepage = "https://github.com/marcus/td";
    license = licenses.mit;
    mainProgram = "td";
    platforms = builtins.attrNames sources;
  };
}
