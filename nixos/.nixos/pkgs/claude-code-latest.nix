{
  claude-code,
}: let
  version = "2.1.281"; # claude-update:version

  platforms = {
    "linux-x64" = {
      binary = "claude.zst";
      checksum = "4ffb9f6baada4d88bbd8c586773efd0605c524c7a31cc3833eeda229717a7b25"; # claude-update:linux-x64
    };
    "linux-arm64" = {
      binary = "claude.zst";
      checksum = "7583b65585561c714e18caca45e0e0fb9bdba6d7ed6ee5d5171834d5c657aea6"; # claude-update:linux-arm64
    };
    "darwin-arm64" = {
      binary = "claude.zst";
      checksum = "056662a4e3a5ca37770730a59345d1b5796ef65444c32b97d236651ab68f3fa1"; # claude-update:darwin-arm64
    };
  };
in
  claude-code.override {
    manifest = {
      inherit version platforms;
    };
  }
