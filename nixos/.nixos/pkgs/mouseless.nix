{ lib, appimageTools, fetchurl, stdenv }:

let
  pname = "mouseless";
  version = "1.0.0-preview.3";

  sources = {
    x86_64-linux = {
      url = "https://github.com/cymian/mouseless/releases/download/v${version}/Mouseless_v${version}_arch-20260510.0.525573_x86_64.AppImage";
      hash = "sha256-xbdHt92VqCksnHho4Riq4GiW4u3xpi47P7J9Oe8VmxQ=";
    };
    aarch64-linux = {
      url = "https://github.com/cymian/mouseless/releases/download/v${version}/Mouseless_v${version}_debian-12_aarch64.AppImage";
      hash = "sha256-yrr5Cma46WAheIF5/eetIAzEWlCMztJdrbCFVy3khLs=";
    };
  };

  src = fetchurl sources.${stdenv.system};
in
appimageTools.wrapAppImage {
  inherit pname version src;

  meta = with lib; {
    description = "Keyboard-driven launcher and window manager companion (mouseless.click)";
    homepage = "https://mouseless.click";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "mouseless";
  };
}
