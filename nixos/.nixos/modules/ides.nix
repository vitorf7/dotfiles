{ ... }:
{
  flake.modules.darwin.ides = { ... }: {
    homebrew.casks = [
      "cursor"
      "visual-studio-code@insiders"
      "jetbrains-toolbox"
    ];
  };
}
