{...}: {
  # macOS: install via Homebrew cask
  flake.modules.darwin.notes = {...}: {
    homebrew.casks = ["obsidian"];
  };

  # All platforms: install package (Linux only) + symlink config
  flake.modules.homeManager.notes = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [pkgs.obsidian];
  };
}
