{ ... }:
{
  flake.modules.darwin.databases = { ... }: {
    homebrew.casks = [
      "beekeeper-studio"
      "dbeaver-community"
      "insomnia"
      "postman"
    ];
  };
}
