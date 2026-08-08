{ ... }:
{
  flake.modules.darwin.git = { ... }: {
    homebrew.taps = [{ name = "chmouel/lazyworktree"; clone_target = "https://github.com/chmouel/lazyworktree"; force_auto_update = null; }];
    homebrew.extraConfig = ''
      cask "chmouel/lazyworktree/lazyworktree", trusted: true
    '';
  };

  flake.modules.homeManager.git = { config, pkgs, lib, osConfig, ... }:
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
      defaultInclude = [{
        path = if gitCfg.defaultProfile == "work" then workTemplatePath else personalTemplatePath;
      }];
      personalIncludes = lib.optionals (gitCfg.personal.enable && gitCfg.defaultProfile != "personal")
        (map (dir: { condition = "gitdir:${dir}"; path = personalTemplatePath; }) gitCfg.personal.directories);
      workIncludes = lib.optionals (gitCfg.work.enable && gitCfg.defaultProfile != "work")
        (map (dir: { condition = "gitdir:${dir}"; path = workTemplatePath; }) gitCfg.work.directories);
    in
    {
      programs.git = {
        enable = true;
        signing = {
          signByDefault = true;
          format = "ssh";
          signer = opSshSignPath;
        };
        ignores = [
          "npm-debug.log" ".DS_Store" "Thumbs.db" ".idea/" "*~" "*.swp"
          ".vscode" "*.log" ".worktrees" "coverage.out" ".cursor/" ".claude/"
          "mise.toml" ".tokensave"
        ];
        includes = defaultInclude ++ personalIncludes ++ workIncludes;
        maintenance.enable = true;
        settings = {
          core.editor = "nvim";
          init.defaultBranch = "master";
          status.short = true;
          merge.conflictstyle = "diff3";
          diff.colorMoved = "default";
          alias = {
            leaderboard = "shortlog --summary --numbered --all --no-merges";
            sbr = "!rm \${GIT_PREFIX}$1 && git checkout -- \${GIT_PREFIX}$1 #";
            who = "blame -w -M -C -C -C";
          };
          "filter \"strongbox\"" = {
            clean = "strongbox -clean %f";
            smudge = "strongbox -smudge %f";
            required = true;
          };
          "diff \"strongbox\"".textconv = "strongbox -diff";
          "credential \"https://github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
          "credential \"https://gist.github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
          url."git@github.com:".insteadOf = "https://github.com/";
        };
      };

      programs.delta = {
        enable = true;
        enableGitIntegration = true;
        options = { navigate = true; side-by-side = true; };
      };

      programs.gh = {
        enable = true;
        settings = {
          git_protocol = "ssh";
          editor = "nvim";
          prompt = "enabled";
          pager = "nvimpager";
          aliases = { co = "pr checkout"; pv = "pr view"; };
        };
        extensions = [
          pkgs.gh-dash
          pkgs.gh-pr-review
          pkgs.gh-stack
        ];
      };

      home.packages = with pkgs; [
        lazygit
        gitmux
        tig
        jujutsu
        diff-so-fancy
        difftastic
        ydiff
      ];

      xdg.configFile = {
        "lazygit".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/lazygit/.config/lazygit";
        "gh-dash".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/gh-dash/.config/gh-dash";
      };
    };
}
