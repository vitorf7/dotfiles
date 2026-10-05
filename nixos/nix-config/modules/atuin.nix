{...}: {
  # Atuin shell history, purely local: SQLite at ~/.local/share/atuin,
  # auto_sync off, cross-machine sharing via manual DB copy
  # (atuin-db-push / atuin-db-pull fish functions). Fish init lives in
  # fish/.config/fish/config.fish.
  #
  # The local Atuin AI stack (Ollama + atuin-ai-server container) was removed:
  # even with the iGPU/Vulkan build (3x prompt-eval, measured on this
  # machine), gemma4:e4b first-token latency stayed marginal against the
  # ai-server's hardcoded 60s timeout, and the resident RAM cost wasn't
  # worth it. Ctrl-r / atuin search covers command recall.
  flake.modules.homeManager.atuin = {
    config,
    pkgs,
    ...
  }: let
    dot = "${config.home.homeDirectory}/dotfiles";
    link = config.lib.file.mkOutOfStoreSymlink;
  in {
    home.packages = [pkgs.atuin];

    xdg.configFile."atuin/config.toml".source = link "${dot}/atuin/.config/atuin/config.toml";
  };
}
