{
  claude-code,
}: let
  version = "2.1.317"; # claude-update:version

  platforms = {
    "linux-x64" = {
      binary = "claude.zst";
      checksum = "cd557f900744b6aa1a554f7fd3f64788680d93f396eb760590414db4c6d53ccb"; # claude-update:linux-x64
    };
    "linux-arm64" = {
      binary = "claude.zst";
      checksum = "f6279f0c17270c20f47bdd71ef2d5408a53c4dba978c9e805aadac4232f3ea51"; # claude-update:linux-arm64
    };
    "darwin-arm64" = {
      binary = "claude.zst";
      checksum = "f2e220b0994b475e86d96b44a649252d75e083e505a228f2ff0c0fc266481595"; # claude-update:darwin-arm64
    };
  };
in
  claude-code.override {
    manifest = {
      inherit version platforms;
    };
  }
