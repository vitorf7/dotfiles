{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.0.0"; # go-update:version

  platform = {
    x86_64-linux = {
      suffix = "linux-amd64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # go-update:x86_64-linux
    };
    aarch64-linux = {
      suffix = "linux-arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # go-update:aarch64-linux
    };
    aarch64-darwin = {
      suffix = "darwin-arm64";
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # go-update:aarch64-darwin
    };
  }.${stdenvNoCC.hostPlatform.system}
    or (throw "Unsupported system: ${stdenvNoCC.hostPlatform.system}");
in

stdenvNoCC.mkDerivation {
  pname = "go";
  inherit version;

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${platform.suffix}.tar.gz";
    inherit (platform) hash;
  };

  sourceRoot = "go";

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp -r . $out/share/go
    ln -s $out/share/go/bin/go $out/bin/go
    ln -s $out/share/go/bin/gofmt $out/bin/gofmt
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Go programming language (official binary from go.dev)";
    homepage = "https://go.dev";
    license = licenses.bsd3;
  };
}
