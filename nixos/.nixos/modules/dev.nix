{ self, ... }:
{
  flake.modules.homeManager.dev = { pkgs, ... }: {
    home.packages = with pkgs; [
      nodejs
      yarn
      python3
      go
      rustup
      opencode
      rtk

      self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
    ];
  };
}
