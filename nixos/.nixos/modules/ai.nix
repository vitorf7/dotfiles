{...}: {
  flake.modules.darwin.ai = {...}: {
    homebrew.casks = [
      "ollama-app"
    ];
  };

  flake.modules.homeManager.ai = {pkgs, ...}: {
    home.packages = with pkgs; [
      opencode
      opencode-claude-auth
      rtk
      claude-code
      fence
    ];
  };
}
