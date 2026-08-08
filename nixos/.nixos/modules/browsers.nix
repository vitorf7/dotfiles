{ inputs, ... }:
{
  flake.modules.darwin.browsers = { ... }: {
    homebrew.casks = [
      "arc"
      "brave-browser"
      "helium-browser"
      "vivaldi"
      "zen"
    ];
  };

  flake.modules.homeManager.browsers = { config, pkgs, lib, osConfig, ... }:
    let
      isLinux = pkgs.stdenv.isLinux;
    in
    lib.mkIf osConfig.vitorf7.desktop.enable {
      home.packages = lib.optionals isLinux [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      xdg.mimeApps.defaultApplications = lib.mkIf isLinux {
        "text/html"                = "zen.desktop";
        "x-scheme-handler/http"    = "zen.desktop";
        "x-scheme-handler/https"   = "zen.desktop";
      };

      home.sessionVariables = lib.mkIf isLinux {
        MOZ_ENABLE_WAYLAND = "1";
      };
    };
}
