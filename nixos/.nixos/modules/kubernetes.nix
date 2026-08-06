{ ... }:
{
  flake.modules.darwin.kubernetes = { ... }: {
    # minikube bundles its own kubectl binary (conflicts with standalone kubectl in buildEnv)
    # ktop aarch64-darwin build broken in nixpkgs — kept on brew
    homebrew.brews = [ "minikube" "ktop" ];
  };

  flake.modules.homeManager.kubernetes = { config, pkgs, ... }:
    let link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.packages = with pkgs; [
        kubectl
        k9s
        kustomize
        argocd
        kubecolor
        kubeconform
        kind
        popeye
        stern
        krew
      ];

      xdg.configFile."k9s".source = link "${config.home.homeDirectory}/dotfiles/k9s/.config/k9s";
    };
}
