{ config, pkgs, lib, osConfig, ... }:

let
  gitCfg = osConfig.vitorf7.git;
  isDarwin = pkgs.stdenv.isDarwin;

  opSshSignPath = if isDarwin
    then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else "/run/current-system/sw/bin/op-ssh-sign";

  personalTemplatePath = config.sops.templates."git-identity-personal".path;
  workTemplatePath = if gitCfg.work.enable
    then config.sops.templates."git-identity-work".path
    else "";

  # Default profile include — unconditional, provides base identity
  defaultInclude = [{
    path = if gitCfg.defaultProfile == "work" then workTemplatePath else personalTemplatePath;
  }];

  # Non-default profile includes — directory-conditional overrides
  personalIncludes = lib.optionals (gitCfg.personal.enable && gitCfg.defaultProfile != "personal")
    (map (dir: {
      condition = "gitdir:${dir}";
      path = personalTemplatePath;
    }) gitCfg.personal.directories);

  workIncludes = lib.optionals (gitCfg.work.enable && gitCfg.defaultProfile != "work")
    (map (dir: {
      condition = "gitdir:${dir}";
      path = workTemplatePath;
    }) gitCfg.work.directories);
in
{
  programs.git = {
    enable = true;

    # Identity (name, email, signingKey) comes from sops-rendered template files
    # included below — not set here so the templates win cleanly.
    signing = {
      signByDefault = true;
      format = "ssh";
      signer = opSshSignPath;
    };

    ignores = [
      "npm-debug.log"
      ".DS_Store"
      "Thumbs.db"
      ".idea/"
      "*~"
      "*.swp"
      ".vscode"
      "*.log"
      ".worktrees"
      "coverage.out"
      ".cursor/"
      ".claude/"
      "mise.toml"
      ".tokensave"
    ];

    includes = defaultInclude ++ personalIncludes ++ workIncludes;

    settings = {
      core.editor = "nvim";
      init.defaultBranch = "master";
      status.short = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";

      alias = {
        leaderboard = "shortlog --summary --numbered --all --no-merges";
        sbr = "!rm \${GIT_PREFIX}$1 && git checkout -- \${GIT_PREFIX}$1 #";
      };

      # Strongbox stays as long as wiresteward-secrets.nix uses it
      "filter \"strongbox\"" = {
        clean = "strongbox -clean %f";
        smudge = "strongbox -smudge %f";
        required = true;
      };
      "diff \"strongbox\"".textconv = "strongbox -diff";

      "credential \"https://github.com\"".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      "credential \"https://gist.github.com\"".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };
}
