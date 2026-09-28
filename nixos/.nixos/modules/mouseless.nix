{...}: {
  flake.modules.nixos.mouseless = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkIf (config.vitorf7.desktop.mouseless.enable && options.services ? flatpak) {
      services.flatpak = {
        remotes = [
          {
            name = "sonuscape";
            location = "https://dl.sonuscape.net/flatpak/sonuscape.flatpakrepo";
          }
        ];
        packages = [
          {
            appId = "net.sonuscape.mouseless";
            origin = "sonuscape";
          }
        ];
        # The app reads its config (symlinked into its sandbox home) from the
        # dotfiles repo, which lives outside the flatpak sandbox.
        overrides.settings."net.sonuscape.mouseless".Context.filesystems = ["~/dotfiles/mouseless:ro"];
      };
    };
  };

  flake.modules.darwin.mouseless = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.vitorf7.desktop.mouseless.enable {
      homebrew.casks = ["mouseless@preview"];
    };
  };

  flake.modules.homeManager.mouseless = {
    osConfig,
    config,
    pkgs,
    lib,
    ...
  }: {
    config =
      lib.mkIf (pkgs.stdenv.isLinux && (osConfig.vitorf7.desktop.mouseless.enable or false)) {
        # The flatpak sandbox cannot follow the standard home-manager symlink
        # chain (it hops through /nix/store, invisible inside the sandbox), so
        # link the app's config path directly to the repo file. The nixos class
        # grants the sandbox read access to ~/dotfiles/mouseless. In-app
        # config editor saves may replace the symlink with a regular file; the
        # next home-manager switch re-links it.
        home.activation.mouselessConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
          $DRY_RUN_CMD mkdir -p "$HOME/.var/app/net.sonuscape.mouseless/data/mouseless/configs" $VERBOSE_ARG
          $DRY_RUN_CMD rm -f "$HOME/.var/app/net.sonuscape.mouseless/data/mouseless/configs/config.yaml" $VERBOSE_ARG
          $DRY_RUN_CMD ln -s "$HOME/dotfiles/mouseless/config-linux.yaml" "$HOME/.var/app/net.sonuscape.mouseless/data/mouseless/configs/config.yaml" $VERBOSE_ARG
        '';
      };
  };
}
