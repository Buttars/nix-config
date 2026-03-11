{
  lib,
  buildGoModule,
  fetchFromGitHub,
  git,
  sqlite,
}:

buildGoModule rec {
  pname = "td";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "marcus";
    repo = "td";
    rev = "v${version}";
    hash = "sha256-lantT8ArHdSHNt3MjX+CKWNVmf7dm2fFdZMmYjlrTx8=";
  };

  vendorHash = "sha256-8mOebFPbf7+hCpn9hUrE0IGu6deEPSujr+yHqrzYEec=";

  # Tests shell out to git + sqlite3
  nativeCheckInputs = [
    git
    sqlite
  ];

  # Run only short tests (skip long/chaos tests if upstream respects testing.Short())
  checkFlags = [ "-short" ];

  ldflags = [
    "-s"
    "-w"
    "-X"
    "main.Version=v${version}"
  ];

  meta = with lib; {
    description = "A minimalist CLI for tracking tasks across AI coding sessions";
    homepage = "https://github.com/marcus/td";
    license = licenses.mit;
    mainProgram = "td";
  };
}
