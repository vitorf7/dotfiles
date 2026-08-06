{ ... }:
{
  flake.modules.homeManager.darwin-packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      # Build / dev toolchain
      cmake ninja pkg-config pre-commit stylua shellcheck semgrep richgo

      # Shell / TUI utilities
      btop chafa diff-so-fancy difftastic entr evans figlet findutils
      glow gnugrep gnused graphviz gum jless jujutsu libsixel luarocks
      mas moreutils nowplaying-cli pipenv pngpaste poppler
      scdoc superfile switchaudio-osx tectonic television
      terminal-notifier tlrc tree uv wakatime-cli watchman
      wget wimlib xh yazi ydiff yq-go
      ghostscript imagemagick ffmpegthumbnailer
    ];
  };
}
