{ lib
, fetchFromGitHub
, glib
, gnome-desktop
, gobject-introspection
, gtk4
, libadwaita
, python3Packages
, wrapGAppsHook4
}:

# Derivations for the five Python deps that aren't in nixpkgs yet.
# Track https://github.com/NixOS/nixpkgs/pull/505419 — once merged, replace
# this file with a simple `pkgs.hyprmod` reference.

let
  hyprland-socket = python3Packages.buildPythonPackage {
    pname = "hyprland-socket";
    version = "0.12.1";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "BlueManCZ";
      repo = "hyprland-socket";
      tag = "v0.12.1";
      hash = "sha256-xZh0re/bfWM0Nwv9bx/EsyE3coJjxhSpRiau/6Bg1Nc=";
    };
    build-system = [ python3Packages.hatchling ];
    doCheck = false;
    meta.description = "Typed Python library for Hyprland IPC via Unix sockets";
  };

  hyprland-config = python3Packages.buildPythonPackage {
    pname = "hyprland-config";
    version = "0.9.6";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "BlueManCZ";
      repo = "hyprland-config";
      tag = "v0.9.6";
      hash = "sha256-c+2eZyDdFTmcqqiESjjo6PPN2G4uGpp66UtGBlDiV2M=";
    };
    build-system = [ python3Packages.hatchling ];
    doCheck = false;
    meta.description = "Round-trip parser and editor for Hyprland configuration files";
  };

  hyprland-schema = python3Packages.buildPythonPackage {
    pname = "hyprland-schema";
    version = "0.6.1";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "BlueManCZ";
      repo = "hyprland-schema";
      tag = "v0.6.1";
      hash = "sha256-w0fWQkSziNYZtgtqm1El5fP+fCmFMpMf21uo9cf/vqA=";
    };
    build-system = [ python3Packages.hatchling ];
    doCheck = false;
    meta.description = "Typed Python schema for every Hyprland configuration option";
  };

  hyprland-monitors = python3Packages.buildPythonPackage {
    pname = "hyprland-monitors";
    version = "0.7.0";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "BlueManCZ";
      repo = "hyprland-monitors";
      tag = "v0.7.0";
      hash = "sha256-83h9rcavYie9QYjRMmN3akmALS+4orvMldIUt7vf/Qc=";
    };
    build-system = [ python3Packages.hatchling ];
    dependencies = [ hyprland-socket ];
    doCheck = false;
    meta.description = "Monitor management utilities for Hyprland";
  };

  hyprland-state = python3Packages.buildPythonPackage {
    pname = "hyprland-state";
    version = "0.4.2";
    pyproject = true;
    src = fetchFromGitHub {
      owner = "BlueManCZ";
      repo = "hyprland-state";
      tag = "v0.4.2";
      hash = "sha256-HvkVFFPh5mDNcOMRpKjznoCN7Q77DL6LZ9BhPGHs0PI=";
    };
    build-system = [ python3Packages.hatchling ];
    dependencies = [ hyprland-config hyprland-monitors hyprland-schema hyprland-socket ];
    doCheck = false;
    meta.description = "Live state interface for Hyprland";
  };
in

python3Packages.buildPythonApplication {
  pname = "hyprmod";
  version = "0.3.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "BlueManCZ";
    repo = "hyprmod";
    tag = "v0.3.0";
    hash = "sha256-oO7tibfdaM6IgpZQEUItahtpSgFjlIffDyhcTBJiSRQ=";
  };

  build-system = [ python3Packages.hatchling ];

  nativeBuildInputs = [
    glib
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    gnome-desktop
    gtk4
    libadwaita
  ];

  dependencies = with python3Packages; [
    hyprland-config
    hyprland-monitors
    hyprland-schema
    hyprland-socket
    hyprland-state
    pygobject3
    pygobject-stubs
  ];

  pythonRelaxDeps = [ "pygobject" ];

  # Correct wrapper approach for both x86_64 and aarch64
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postInstall = ''
    install -Dm0644 data/applications/io.github.bluemancz.hyprmod.desktop \
      -t $out/share/applications
    install -Dm0644 data/icons/hicolor/scalable/apps/io.github.bluemancz.hyprmod.svg \
      -t $out/share/icons/hicolor/scalable/apps
    install -Dm0644 data/metainfo/io.github.bluemancz.hyprmod.metainfo.xml \
      -t $out/share/metainfo
  '';

  doCheck = false;

  meta = with lib; {
    description = "Native GTK4/libadwaita settings application for Hyprland";
    homepage = "https://github.com/BlueManCZ/hyprmod";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    mainProgram = "hyprmod";
  };
}
