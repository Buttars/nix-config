{
  lib,
  appimageTools,
  fetchurl,
}:
let
  pname = "reticulum-meshchat";
  version = "2.4.0";

  src = fetchurl {
    url = "https://github.com/liamcottle/reticulum-meshchat/releases/download/v${version}/ReticulumMeshChat-v${version}-linux.AppImage";
    hash = "sha256-RWJj1ZsjD0pWUcvhtwTK38HGmCbETv2icsmLX+WVgr4=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/reticulum-meshchat.desktop -t $out/share/applications
    install -Dm444 ${appimageContents}/reticulum-meshchat.png -t $out/share/icons/hicolor/0x0/apps
    substituteInPlace $out/share/applications/reticulum-meshchat.desktop \
      --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox %U'
  '';

  meta = {
    description = "Mesh network communications app powered by the Reticulum Network Stack";
    homepage = "https://github.com/liamcottle/reticulum-meshchat";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
