{ ... }:
{
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

  flake.modules.darwin.docker = { config, pkgs, lib, ... }:
    let cfg = config.vitorf7.darwin; in
    {
      launchd.user.agents = lib.mkIf cfg.colima.enable {
        colima = {
          serviceConfig = {
            Label = "com.github.abiosoft.colima";
            ProgramArguments = [ "${pkgs.colima}/bin/colima" "daemon" ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "/Users/${config.system.primaryUser}/Library/Logs/colima.out.log";
            StandardErrorPath = "/Users/${config.system.primaryUser}/Library/Logs/colima.err.log";
            EnvironmentVariables.HOME = "/Users/${config.system.primaryUser}";
          };
        };
      };
    };
}
