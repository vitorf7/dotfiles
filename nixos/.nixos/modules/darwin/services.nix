{ config, pkgs, lib, ... }:

let cfg = config.vitorf7.darwin; in

{
  # Colima container runtime — starts the colima daemon at login.
  # If colima start/stop via this agent proves unreliable, set
  # vitorf7.darwin.colima.enable = false and run `colima start` manually.
  launchd.user.agents = lib.mkIf cfg.colima.enable {
    colima = {
      serviceConfig = {
        Label = "com.github.abiosoft.colima";
        ProgramArguments = [ "${pkgs.colima}/bin/colima" "daemon" ];
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/colima.out.log";
        StandardErrorPath = "/tmp/colima.err.log";
        EnvironmentVariables = {
          HOME = "/Users/${config.system.primaryUser}";
        };
      };
    };
  };
}
