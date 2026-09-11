{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:
buildGoModule rec {
  pname = "wiresteward";
  version = "0.3.5";

  src = fetchFromGitHub {
    owner = "utilitywarehouse";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3WN+CrLOBHMsmMnLBB4KR9R1p1CbbxzF/J1FBIRih7I=";
  };

  # Tests require kernel WireGuard interfaces and iptables — not available in
  # the Nix sandbox.
  doCheck = false;

  vendorHash = "sha256-r9WSzSvntsNcR4y9FN0h/c4BgKeNvdf05PLYT9Z4zc4=";

  meta = {
    description = "WireGuard peer manager with OAuth2 authentication";
    homepage = "https://github.com/utilitywarehouse/wiresteward";
    license = lib.licenses.mit;
    mainProgram = "wiresteward";
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [fromSource];
  };
}
