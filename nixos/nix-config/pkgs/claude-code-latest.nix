{
  claude-code,
}: let
  version = "2.1.306"; # claude-update:version

  platforms = {
    "linux-x64" = {
      binary = "claude.zst";
      checksum = "e5a0284d14ae555ef208c6d2987e29f298cb3bb69a7497c9f24217980233acd3"; # claude-update:linux-x64
    };
    "linux-arm64" = {
      binary = "claude.zst";
      checksum = "0af97e326ddc5260d40d50192f5b46a17237aabd90f8768c3ee38111975ff2d7"; # claude-update:linux-arm64
    };
    "darwin-arm64" = {
      binary = "claude.zst";
      checksum = "5716c3679354804b7cf338de9a9c49941e53c2f3264181851f98959d7a74dd2e"; # claude-update:darwin-arm64
    };
  };
in
  claude-code.override {
    manifest = {
      inherit version platforms;
    };
  }
