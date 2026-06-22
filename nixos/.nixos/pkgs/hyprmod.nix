{ lib
, python3Packages
, fetchFromGitHub
, gtk4
, libadwaita
, gobject-introspection
, wrapGAppsHook4
}:

python3Packages.buildPythonApplication rec {
  pname = "hyprmod";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "BlueManCZ";
    repo = "hyprmod";
    rev = "v${version}";
    # We use a placeholder hash. Nix will fail on the first run, 
    # print the correct cryptographic SHA-256 hash, and you can paste it here.
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  pyproject = true;

  # Native build tools needed at compilation time
  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    python3Packages.setuptools
  ];

  # System libraries the application links against
  buildInputs = [
    gtk4
    libadwaita
  ];

  # Python runtime dependencies
  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  meta = with lib; {
    description = "A GUI application to modify your Hyprland configuration live";
    homepage = "https://github.com/BlueManCZ/hyprmod";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
