{ self, ... }:
{
  flake.modules.darwin.dev = { ... }: {
    homebrew.taps = [
      "hashicorp/tap"
      "snyk/tap"
      "teamookla/speedtest"
    ];
    homebrew.brews = [
      "hashicorp/tap/terraform"
      "hashicorp/tap/terraform-ls"
      "snyk/tap/snyk"
      "teamookla/speedtest/speedtest"
      "awscli@1"
      "julia"
      "cocoapods"
      "composer"
      "openjdk"
    ];
  };

  flake.modules.homeManager.dev = { pkgs, lib, ... }:
    let
      isDarwin = pkgs.stdenv.isDarwin;
    in
    {
      home.packages = with pkgs; [
        nodejs
        yarn
        python3
        go
        rustup

        self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
      ] ++ lib.optionals isDarwin [
        cmake ninja pkg-config pre-commit stylua shellcheck semgrep richgo
        luarocks watchman wakatime-cli tectonic uv pipenv
      ];
    };
}
