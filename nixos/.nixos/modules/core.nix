{ ... }:
{
  flake.modules.homeManager.core = { config, pkgs, lib, ... }:
    let
      dot = "${config.home.homeDirectory}/dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;
      isLinux = pkgs.stdenv.isLinux;
    in
    {
      home.packages = with pkgs; [
        gcc
        gnumake
        unzip
        curl
        stow
        sops
        mise
        rbenv
        fx
        jq
      ] ++ lib.optionals isLinux [
        killall
        nix-ld
        os-prober
      ];
    };
}
