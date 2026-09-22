{...}: {
  flake.modules.homeManager.shell = {
    config,
    pkgs,
    lib,
    ...
  }: let
    dot = "${config.home.homeDirectory}/dotfiles";
    link = config.lib.file.mkOutOfStoreSymlink;
    isLinux = pkgs.stdenv.isLinux;
    isDarwin = pkgs.stdenv.isDarwin;
  in {
    home.packages = with pkgs;
      [
        tmux
        starship
        zoxide
        fzf
        bat
        eza
        direnv
        sesh
        fastfetch
        ripgrep
        fd
        # nh is needed for the `nrs` and `hm` fish aliases on both Linux and macOS.
        nh
      ]
      ++ lib.optionals isLinux [
        # Wayland colour-generation + wallpaper (not needed without Hyprland on darwin)
        matugen
        awww
      ]
      ++ lib.optionals isDarwin [
        reattach-to-user-namespace
        btop
        chafa
        entr
        figlet
        findutils
        glow
        gnugrep
        gnused
        gum
        jless
        libsixel
        moreutils
        pngpaste
        superfile
        television
        terminal-notifier
        tlrc
        tree
        wget
        xh
        yazi
      ];

    xdg.configFile =
      lib.optionalAttrs isDarwin {
        "superfile".source = link "${dot}/superfile/.config/superfile";
        "lf".source = link "${dot}/lf/.config/lf";
      }
      // {
        "fish/config.fish".source = link "${dot}/fish/.config/fish/config.fish";
        "fish/aliases.fish".source = link "${dot}/fish/.config/fish/aliases.fish";
        "fish/functions/sudo.fish".text = ''
          function sudo --wraps sudo --description 'sudo with reattach-to-user-namespace'
            if command -q reattach-to-user-namespace
              reattach-to-user-namespace (command -s sudo) $argv
            else
              command sudo $argv
            end
          end
        '';
        "fish/fish_plugins".source = link "${dot}/fish/.config/fish/fish_plugins";
        # Fish functions are enumerated one by one on purpose: fisher writes its
        # own plugin functions into ~/.config/fish/functions at runtime, so this
        # directory cannot be a single out-of-store symlink without home-manager
        # fighting fisher over ownership of it.
        #
        # Consequence: adding a .fish file to the repo does nothing until it is
        # declared here AND `hm` has run. Editing a file already listed below is
        # live immediately, since these are out-of-store symlinks into the repo.
        "fish/functions/nvims.fish".source = link "${dot}/fish/.config/fish/functions/nvims.fish";
        "fish/functions/__sops_key_file.fish".source = link "${dot}/fish/.config/fish/functions/__sops_key_file.fish";
        "fish/functions/sops-edit.fish".source = link "${dot}/fish/.config/fish/functions/sops-edit.fish";
        "fish/functions/sops-view.fish".source = link "${dot}/fish/.config/fish/functions/sops-view.fish";
        "fish/functions/sops-updatekeys.fish".source = link "${dot}/fish/.config/fish/functions/sops-updatekeys.fish";
        "fish/functions/auth_apix.fish".source = link "${dot}/fish/.config/fish/functions/auth_apix.fish";
        "fish/functions/auth_junifer.fish".source = link "${dot}/fish/.config/fish/functions/auth_junifer.fish";
        "fish/functions/grpc-test.fish".source = link "${dot}/fish/.config/fish/functions/grpc-test.fish";
        "fish/completions/apix.fish".source = link "${dot}/fish/.config/fish/completions/apix.fish";
        "tmux".source = link "${dot}/tmux/.config/tmux";
        "starship.toml".source = link "${dot}/starship/.config/starship.toml";
        "bat".source = link "${dot}/bat/.config/bat";
        "fastfetch".source = link "${dot}/fastfetch/.config/fastfetch";
      };

    home.file.".tmux.conf".source = link "${dot}/tmux/.tmux.conf";

    # NH_FLAKE lets the `nh` helper default to this flake for `nh home`, `nh os`,
    # and `nh darwin` commands. It is set here for both Linux and macOS so the
    # `nrs` and `hm` fish aliases work the same way on both platforms.
    # NH_SHOW_ACTIVATION_LOGS restores the activation-script output (e.g. the
    # Homebrew update/upgrade log) that `nh` hides by default since 4.3.0.
    home.sessionVariables = {
      NH_FLAKE = "${config.home.homeDirectory}/dotfiles/nixos/.nixos";
      NH_SHOW_ACTIVATION_LOGS = "1";
    };
  };
}
