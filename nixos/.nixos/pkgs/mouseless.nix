{
  lib,
  appimageTools,
  fetchurl,
  stdenv,
}: let
  # Per-platform release asset, keyed by version so a bump only needs the
  # version + hashes updated here — not a sibling attribute of the final
  # derivation, since nixpkgs would try to stringify it as an env var.
  sourcesFor = version: {
    x86_64-linux = {
      url = "https://github.com/cymian/mouseless/releases/download/v${version}/Mouseless_v${version}_arch-20260510.0.525573_x86_64.AppImage";
      hash = "sha256-xbdHt92VqCksnHho4Riq4GiW4u3xpi47P7J9Oe8VmxQ=";
    };
    aarch64-linux = {
      url = "https://github.com/cymian/mouseless/releases/download/v${version}/Mouseless_v${version}_debian-12_aarch64.AppImage";
      hash = "sha256-yrr5Cma46WAheIF5/eetIAzEWlCMztJdrbCFVy3khLs=";
    };
  };
in
  appimageTools.wrapAppImage rec {
    pname = "mouseless";
    version = "1.0.0-preview.3";
    src = fetchurl (sourcesFor version).${stdenv.system};

    meta = with lib; {
      description = "Keyboard-driven launcher and window manager companion (mouseless.click)";
      homepage = "https://mouseless.click";
      license = licenses.unfree;
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "mouseless";
    };
  }
