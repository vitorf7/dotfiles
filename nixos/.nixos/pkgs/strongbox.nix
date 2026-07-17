{ buildGoModule, fetchFromGitHub, lib, }:
buildGoModule rec {
  pname = "strongbox";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "uw-labs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-KVaFddlPwmHpwR4gotpKYC/5UC9uQmSB5QfJQvl+/24=";
  };
  vendorHash = "sha256-Gu4hPsDE20d5MUmnp2mYrmRxFfWQ5qcQvvd1h9SvJ94=";

  meta = with lib; {
    description = "Encryption for git users";
    homepage = "https://github.com/uw-labs/strongbox";
    platforms = platforms.all;
  };
}
