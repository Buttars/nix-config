{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation {
  pname = "pixelon";
  version = "1.0";

  src = fetchzip {
    url = "https://www.fontspace.com/get/family/0qozy";
    # Replace this with the real hash:
    # nix-prefetch-url --unpack https://www.fontspace.com/get/family/0qozy
    sha256 = "sha256-0p0haqvhm9a43bfc61a7hn5bkd3c3k45lgd43mw1g7rjynyzv9vg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -dm755 $out/share/fonts/truetype
    install -dm755 $out/share/fonts/opentype

    find . -type f -iname '*.ttf' -exec install -Dm644 '{}' "$out/share/fonts/truetype/" \;
    find . -type f -iname '*.otf' -exec install -Dm644 '{}' "$out/share/fonts/opentype/" \;

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pixelon font from FontSpace";
    homepage = "https://www.fontspace.com";
    license = licenses.unfreeRedistributable; # Update if you find a published license
    platforms = platforms.all;
  };
}
