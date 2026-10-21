{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.69.0";

  sources = {
    x86_64-linux = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_linux_amd64.tar.gz";
      hash = "sha256-wMp45Z93iH6MZU7NNLbSqRQmmZ74Gd0CjX68x4Cp09A=";
    };
    aarch64-linux = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_linux_arm64.tar.gz";
      hash = "sha256-mYmeNR4YEQ1jNX7YvgN44gCmaZAvwHtqnH/mXkp0ou0=";
    };
    x86_64-darwin = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_darwin_amd64.tar.gz";
      hash = "sha256-wY7vAbDEtP/ICzK6YyPVFmcquD3yj2uFQppz8yoMXgQ=";
    };
    aarch64-darwin = {
      url = "https://github.com/marcus/td/releases/download/v${version}/td_${version}_darwin_arm64.tar.gz";
      hash = "sha256-DBDWqx5xhI12II/wWMPYgj/wxmDaQj3OjCocC00fupI=";
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
