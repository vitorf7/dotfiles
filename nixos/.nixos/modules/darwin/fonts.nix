{ pkgs, ... }:

{
  # Nerd fonts and free fonts via nixpkgs — installed to ~/Library/Fonts/Nix Fonts/.
  # After confirming these work, remove the corresponding brew cask entries in homebrew.nix.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono    # replaces cask font-jetbrains-mono-nerd-font
    nerd-fonts.hack              # replaces cask font-hack-nerd-font
    nerd-fonts.meslo-lg          # replaces cask font-meslo-lg-nerd-font
    nerd-fonts.symbols-only      # replaces cask font-symbols-only-nerd-font
    nerd-fonts.monaspace         # replaces cask font-monaspace; provides MonaspiceRn Nerd Font Mono/Propo
    commit-mono                  # replaces cask font-commit-mono
    noto-fonts-color-emoji       # replaces cask font-noto-color-emoji
  ];
}
