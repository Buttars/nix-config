{
  lib,
  stdenvNoCC,
  nebula-sans,
  fontforge,
  nerd-font-patcher,
}:

stdenvNoCC.mkDerivation {
  pname = "nebula-sans-nerdfont";
  inherit (nebula-sans) version;

  src = nebula-sans;

  nativeBuildInputs = [
    fontforge
    nerd-font-patcher
  ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p patched
    find "$src/share/fonts" -name '*.ttf' -print0 \
      | xargs -0 -P "''${NIX_BUILD_CORES:-1}" -I {} \
          nerd-font-patcher --complete --quiet --outputdir patched {}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/share/fonts/truetype patched/*.ttf
    runHook postInstall
  '';

  meta = {
    description = "Nerd Font patch of Nebula Sans";
    inherit (nebula-sans.meta) homepage license;
    platforms = lib.platforms.all;
  };
}
