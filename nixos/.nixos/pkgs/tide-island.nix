{ lib
, stdenv
, fetchFromGitHub
, cmake
, qt6
, systemd
, quickshell
}:

# Custom derivation for Tide Island — a Quickshell/Qt6-based Dynamic Island
# widget for Hyprland. Not yet in nixpkgs.
# https://github.com/enhaoswen/Tide-island
# Last updated for Tide Island v1.0.20.

stdenv.mkDerivation {
  pname = "tide-island";
  version = "1.0.20";

  src = fetchFromGitHub {
    owner = "enhaoswen";
    repo = "Tide-island";
    tag = "1.0.20";
    hash = "sha256-6fEuql1DfGv/q+IO2FWbcHwVUpStVJ3o1Ax+9KIrJh4=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative    # Qt6::Qml, Qt6::Quick, Qt6::QuickControls2, Qt6::QuickDialogs2
    qt6.qtwayland        # Wayland integration
    qt6.qtconnectivity   # Qt6::Bluetooth (BluetoothPairingAgent, WifiController)
    qt6.qtsvg            # SVG icon rendering
    systemd              # libudev (find_library UDEV_LIB)
    quickshell           # runtime dep for the launcher wrapper
  ];

  postPatch = ''
    # The upstream CMakeLists.txt hardcodes /usr/lib/systemd/user as an
    # absolute destination, which breaks in the Nix sandbox. Redirect to a
    # GNUInstallDirs-relative path so it lands in $out/lib/systemd/user.
    substituteInPlace CMakeLists.txt \
      --replace-fail \
        'DESTINATION /usr/lib/systemd/user' \
        'DESTINATION ''${CMAKE_INSTALL_LIBDIR}/systemd/user'
  '';

  # wrapQtAppsHook auto-adds a package's own QML dir to NIXPKGS_QT6_QML_IMPORT_PATH
  # only when it exists at lib/qt-6/qml (the nixpkgs-canonical path with hyphen).
  # Tide-island installs to lib/qt6/qml (no hyphen, the upstream CMake default), so
  # the hook's qtOwnPathsHook never picks it up. Declare it explicitly here so that
  # the ELF tide-island-config-app gets it in its C wrapper.
  #
  # libQt6Qml.so.6 reads NIXPKGS_QT6_QML_IMPORT_PATH natively (nixpkgs Qt patch),
  # making both the config app and the quickshell-launched main widget aware of the
  # IslandBackend and TideIsland modules.
  qtWrapperArgs = [
    "--prefix NIXPKGS_QT6_QML_IMPORT_PATH : ${builtins.placeholder "out"}/lib/qt6/qml"
  ];

  postInstall = ''
    # Patch the launcher script to use nix-store paths instead of the
    # Arch Linux-style /usr/bin and /usr/share prefixes.
    substituteInPlace $out/bin/tide-island \
      --replace-fail '/usr/bin/quickshell' '${quickshell}/bin/quickshell' \
      --replace-fail '/usr/share/tide-island' "$out/share/tide-island"

    # Remove a stale Qt QRC map file left over by the build system
    # (mirrors the cleanup step in the upstream PKGBUILD).
    rm -f $out/lib/qt6/qml/TideIsland/tide-island-config-app_qml_module_dir_map.qrc

    # wrapQtAppsHook skips the tide-island bash launcher (it only wraps ELF files).
    # wrapProgram creates a shell wrapper for it so quickshell inherits the right
    # QML import paths. QML_IMPORT_PATH is included as a belt-and-suspenders
    # fallback alongside NIXPKGS_QT6_QML_IMPORT_PATH.
    wrapProgram "$out/bin/tide-island" \
      --prefix NIXPKGS_QT6_QML_IMPORT_PATH : "$out/lib/qt6/qml" \
      --prefix QML_IMPORT_PATH             : "$out/lib/qt6/qml"
  '';

  meta = with lib; {
    description = "Smooth, lightweight Dynamic Island widget for Hyprland (Quickshell/Qt6)";
    homepage = "https://github.com/enhaoswen/Tide-island";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "tide-island";
  };
}
