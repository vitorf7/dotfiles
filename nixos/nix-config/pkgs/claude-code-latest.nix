{
  claude-code,
}: let
  version = "2.1.296"; # claude-update:version

  platforms = {
    "linux-x64" = {
      binary = "claude.zst";
      checksum = "fac1d78be9446052ac084878c04c2648abb6b22d53279a685fa19ee517d74410"; # claude-update:linux-x64
    };
    "linux-arm64" = {
      binary = "claude.zst";
      checksum = "23aa91437a06eff80a65bfc32b0e4b5a6dda3e821019c543696c154274e56913"; # claude-update:linux-arm64
    };
    "darwin-arm64" = {
      binary = "claude.zst";
      checksum = "26426aa3dcf41b0f554951766c3c583cf243345ca3d32fa590caf84685be5f97"; # claude-update:darwin-arm64
    };
  };
in
  claude-code.override {
    manifest = {
      inherit version platforms;
    };
  }
