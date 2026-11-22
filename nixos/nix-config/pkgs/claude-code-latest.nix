{
  claude-code,
}: let
  version = "2.1.330"; # claude-update:version

  platforms = {
    "linux-x64" = {
      binary = "claude.zst";
      checksum = "d53a3f9aab93c87bba0813d1101677677b457100824f5c3604fea9915ac5237a"; # claude-update:linux-x64
    };
    "linux-arm64" = {
      binary = "claude.zst";
      checksum = "fd32a5b1552693c801e6f6cb3dc77e39c2438a873d00600558bae8bdc06b20bd"; # claude-update:linux-arm64
    };
    "darwin-arm64" = {
      binary = "claude.zst";
      checksum = "c909e975f01193126bf28da4fa66825db4e9d10fd52b217106fdb3b9c7f6d247"; # claude-update:darwin-arm64
    };
  };
in
  claude-code.override {
    manifest = {
      inherit version platforms;
    };
  }
