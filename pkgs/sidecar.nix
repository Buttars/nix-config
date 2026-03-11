{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  sqlite,
}:

buildGoModule rec {
  pname = "sidecar";
  version = "0.74.0";

  src = fetchFromGitHub {
    owner = "marcus";
    repo = "sidecar";
    rev = "v${version}";
    hash = "sha256-+7Qa5/WcF3Apk4f35l8/UgIJf407okch/S4wBj5OfRc=";
  };

  subPackages = [ "cmd/sidecar" ];

  vendorHash = "sha256-eqB5NIJPqlHCXj78h7gnYAgvXgRu7nPaXdAPVLzdOUw=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ sqlite ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=v${version}"
  ];

  meta = with lib; {
    description = "Use sidecar next to CLI agents for diffs, file trees, conversation history, and task management";
    homepage = "https://github.com/marcus/sidecar";
    license = licenses.mit;
    mainProgram = "sidecar";
  };
}
