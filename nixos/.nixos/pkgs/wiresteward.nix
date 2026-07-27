{
  buildGoModule,
  fetchFromGitHub,
  lib,
}:

buildGoModule rec {
  pname = "wiresteward";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "utilitywarehouse";
    repo = pname;
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  # Tests require kernel WireGuard interfaces and iptables — not available in
  # the Nix sandbox.
  doCheck = false;

  vendorHash = lib.fakeHash;

  meta = {
    description = "WireGuard peer manager with OAuth2 authentication";
    homepage = "https://github.com/utilitywarehouse/wiresteward";
    license = lib.licenses.mit;
    mainProgram = "wiresteward";
    platforms = lib.platforms.all;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
