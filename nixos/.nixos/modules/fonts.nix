{ ... }:
let
  fontPackages = { pkgs, ... }: {
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.meslo-lg
      nerd-fonts.symbols-only
      nerd-fonts.monaspace
      commit-mono
      noto-fonts-color-emoji
    ];
  };
in
{
  flake.modules.nixos.fonts  = fontPackages;
  flake.modules.darwin.fonts = fontPackages;
}
