{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "truenas-mcp";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "truenas";
    repo = "truenas-mcp";
    rev = "v${version}";
    hash = "sha256-R+d6qiFM9mwrAXqA8X+m4/x7+pUTq0zN7jshScSgl0o=";
  };

  vendorHash = "sha256-0A+zS5N+LZ7yRabl6BvovpZPq9NErroW21sRfiMTA+c=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    description = "MCP server for TrueNAS";
    homepage = "https://github.com/truenas/truenas-mcp";
    license = licenses.asl20;
    mainProgram = "truenas-mcp";
  };
}
