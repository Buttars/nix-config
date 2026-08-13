{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:

let
  version = "0.4.1";

  sources = {
    aarch64-darwin = {
      url = "https://github.com/laulauland/jj-hunk/releases/download/v${version}/jj-hunk-${version}.arm64_sequoia.bottle.tar.gz";
      hash = "sha256-US9BF9CjGLBcHJ036fjCUvljmB121mZ4K7grJNN42hU=";
    };
    x86_64-linux = {
      url = "https://github.com/laulauland/jj-hunk/releases/download/v${version}/jj-hunk-${version}.x86_64_linux.bottle.tar.gz";
      hash = "sha256-TtIiLGMZ5MsT098IncSZkSK88bLMMUhU9nCboW6OzWg=";
    };
  };

  src = fetchurl sources.${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "jj-hunk";
  inherit version src;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 jj-hunk/${version}/bin/jj-hunk $out/bin/jj-hunk
  '';

  meta = with lib; {
    description = "Programmatic hunk selection for jj (Jujutsu)";
    homepage = "https://github.com/laulauland/jj-hunk";
    license = licenses.mit;
    mainProgram = "jj-hunk";
    platforms = builtins.attrNames sources;
  };
}
