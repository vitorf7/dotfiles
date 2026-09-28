{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  python3,
  quickshell,
  slurp,
  coreutils,
}:
  stdenv.mkDerivation rec {
    pname = "quickshell-share-picker";
    version = "0.2.1";

    src = fetchFromGitHub {
      owner = "SamSaffron";
      repo = "quickshell-share-picker";
      rev = "v${version}";
      hash = "sha256-tLn6xy/kLwryNdqdHqGE2/inbThQ2ipC729bsYjNzPU=";
    };

    nativeBuildInputs = [makeWrapper];

    buildInputs = [
      python3
      quickshell
      slurp
      coreutils
    ];

    # Default `make` target is `all: check` which runs tests that depend on
    # scripts/release (not in release tarball). Skip build and go straight to install.
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      make install PREFIX=$out
      wrapProgram $out/bin/quickshell-share-picker \
        --set QSP_SYSTEM_SHARE_DIR "$out/share/quickshell-share-picker" \
        --set QSP_PYTHON_BIN "${python3}/bin/python3" \
        --set QSP_QS_BIN "${quickshell}/bin/qs" \
        --set QSP_SLURP_BIN "${slurp}/bin/slurp" \
        --prefix PATH : "${lib.makeBinPath [coreutils]}"
      runHook postInstall
    '';

    meta = {
      homepage = "https://github.com/SamSaffron/quickshell-share-picker";
      license = lib.licenses.mit;
      description = "One-shot Quickshell screencast source picker for xdg-desktop-portal-hyprland";
    };
  }
