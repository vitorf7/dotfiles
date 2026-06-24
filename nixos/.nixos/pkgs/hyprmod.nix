{ lib
, python3Packages
, fetchFromGitHub
, gtk4
, libadwaita
, gobject-introspection
, wrapGAppsHook4
, stdenv
}:

# To get the correct hash:
#   nix-prefetch-url --unpack https://github.com/BlueManCZ/hyprmod/archive/refs/tags/v0.3.0.tar.gz
# Then convert with:
#   nix hash convert --hash-algo sha256 --from nix32 <output>
# Paste the sha256-... result as the hash below.
#
# ARM (aarch64) note: if the build fails due to gobject-introspection typelib issues,
# add `env.dontWrapGApps = true;` and set GI_TYPELIB_PATH manually in preFixup.

python3Packages.buildPythonApplication rec {
  pname = "hyprmod";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "BlueManCZ";
    repo = "hyprmod";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  pyproject = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    python3Packages.setuptools
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  # Workaround for aarch64 typelib path issues with wrapGAppsHook4
  preFixup = lib.optionalString stdenv.isAarch64 ''
    makeWrapperArgs+=(
      "--prefix" "GI_TYPELIB_PATH" ":" "$GI_TYPELIB_PATH"
      "--prefix" "GDK_PIXBUF_MODULE_FILE" ":" "$GDK_PIXBUF_MODULE_FILE"
    )
  '';

  meta = with lib; {
    description = "A GUI application to modify your Hyprland configuration live";
    homepage = "https://github.com/BlueManCZ/hyprmod";
    license = licenses.mit;
    platforms = platforms.linux;
    # Remove this line once the ARM build is verified:
    broken = stdenv.isAarch64;
  };
}
