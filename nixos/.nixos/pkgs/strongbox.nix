{ buildGoModule, fetchFromGitHub, lib, }:
buildGoModule rec {
  pname = "strongbox";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "uw-labs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Pzb35KPoeUCRDPVDC6Lloa9bR366enK5QsA8GEcZUe4=";
  };
  vendorHash = "sha256-kAQLg6urkUoMYeqPYv+EJ1XCBz7+0lxWlAn2VPtgxLs=";

  # Integration tests require git in the sandbox PATH — skip them.
  doCheck = false;

  meta = with lib; {
    description = "Encryption for git users";
    homepage = "https://github.com/uw-labs/strongbox";
    platforms = platforms.all;
  };
}
