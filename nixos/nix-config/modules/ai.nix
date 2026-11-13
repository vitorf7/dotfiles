{self, ...}: {
  flake.modules.darwin.ai = {...}: {
    homebrew.casks = [
      "ollama-app"
    ];
  };

  flake.modules.homeManager.ai = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Held on 1.x: opencode-claude-auth (0.7.3) doesn't support OpenCode 2.x.
      # Built from pkgs/opencode-v1.nix; bump with nix-update (see its header).
      self.packages.${pkgs.stdenv.hostPlatform.system}.opencode-v1
      opencode-claude-auth
      rtk
      fence
      self.packages.${pkgs.stdenv.hostPlatform.system}.claude-code-latest
      bubblewrap
    ];
  };
}
