{ lib, appimageTools, fetchurl }:

# mouseless.click is distributed as a Linux AppImage.
# Steps to update:
#   1. Find the latest AppImage URL at https://github.com/elitek7/mouseless/releases
#   2. Run: nix hash file --sri --type sha256 $(nix-prefetch-url --print-path <url> | tail -1)
#   3. Paste the hash below and update version + url.
let
  version = "0.1.0"; # update this
  pname = "mouseless";
in
appimageTools.wrapAppImage {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/elitek7/mouseless/releases/download/v${version}/Mouseless-${version}.AppImage";
    # Replace with the real hash after running the steps above:
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  extraPkgs = pkgs: with pkgs; [
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXrandr
  ];

  meta = with lib; {
    description = "Keyboard-driven browsing and app control (mouseless.click)";
    homepage = "https://mouseless.click";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "mouseless";
  };
}
