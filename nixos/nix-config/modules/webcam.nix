{...}: {
  flake.modules.nixos.webcam = {config, ...}: {
    boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
    boot.kernelModules = ["v4l2loopback"];
    boot.extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
  };

  flake.modules.homeManager.webcam = {pkgs, ...}: {
    home.packages = with pkgs; [guvcview];
  };
}
