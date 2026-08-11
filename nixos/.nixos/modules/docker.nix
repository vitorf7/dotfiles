{ ... }:
{
  flake.modules.nixos.docker = { config, ... }: {
    virtualisation.docker.enable = true;
    users.users.${config.vitorf7.username}.extraGroups = [ "docker" ];
  };

  flake.modules.darwin.docker = { ... }: {};

  flake.modules.homeManager.docker = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      docker
      docker-buildx
      docker-compose
      lazydocker
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      colima
    ];
  };

}
