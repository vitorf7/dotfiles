# Claude Code on NixOS: sandbox deny-glob expansion stalls every command

Draft report for `#tool-claude` / [utilitywarehouse/agentic-coding-mono](https://github.com/utilitywarehouse/agentic-coding-mono).
Local workaround is implemented in this repo (see bottom).

## Summary

With the enterprise sandbox enabled, Claude Code on NixOS stalls ~30-40s (CPU-bound, ~1GB RSS)
before/around every sandboxed command and hook. The cost grows as more NixOS/home-manager
generations accumulate. Root cause: on Linux, the bubblewrap sandbox cannot express glob
patterns, so every wildcard `denyRead` rule is expanded by recursively walking the filesystem
**following symlinked directories** (`walkGlobPattern(..., {followSymlinkedDirectories: true})`
in `@anthropic-ai/sandbox-runtime`). On NixOS `$HOME` is a symlink farm into `/nix/store`,
so the walk cascades through a large fraction of the store — and the managed `~/.*` rule
walks the entire real home.

## Evidence

`SRT_DEBUG=1 claude -p "say hi"` (cwd = a git repo, real `$HOME`, claude-code 2.1.266):

```
[Sandbox] Error expanding glob pattern /home/vitorf7/.*: Error: ELOOP: too many symbolic links encountered, scandir '/home/vitorf7'
[Sandbox] Expanded glob pattern "/home/vitorf7/.*" to 0 paths on Linux
```

- `time claude -p "say hi"` with real `$HOME`: **37.85s**; with a minimal isolated `$HOME`: **9.3s** (rest is model + MCP + hook network latency).
- `strace -f -e trace=openat` shows **~1M+ openat calls** on Nix store symlink chains before the first token.
- Debug log: `[event-loop-stall] blocked for 37378ms ... cpu=37847ms ... rss=1005MB` — synchronous, CPU-bound.
- The `ELOOP` line matters beyond performance: the walk **fails and the `~/.*` deny expands to 0 paths**, i.e. on NixOS this deny is currently **not applied at all** (silently).
- The expansion runs per sandboxed command/hook (memoization is per-wrap only, per sandbox-runtime source), so this cost repeats on every Bash call, and the CrowdStrike hooks sometimes fail with `ECONNRESET` after the stall.
- The walk has no depth limit, no `/nix` exclusion, and its only cycle guard is an ancestor check — sibling/cross links into `/nix/store` are followed.

Same mechanism documented upstream: anthropics/claude-code#74081 and #46461 (per-file bwrap
binds from recursive deny globs → argument-limit failures).

## Ask

In the managed sandbox config (`agentic-coding-mono`), replace wildcard `denyRead`/permission
deny rules that expand against the filesystem on Linux with literal paths or tightly scoped
patterns:

- `sandbox.filesystem.denyRead: ["~/.*", ...]` → enumerate the actual dot paths to deny
  (`.aws`, `.gnupg`, `.kube` is intentionally allowed, ...) as literals. `~/.*` is both the
  performance problem and silently unapplied on NixOS.
- `Read(**/secrets/**)`, `Read(**/*.tfvars)`, `**/.env`, `**/.env.*` → scope to the project
  root (`./**/...`) or use directory-literal denies; each recursive glob re-walks the tree on
  every command.

macOS is unaffected (Seatbelt evaluates globs natively), which is why this only bites Linux
devs — primarily NixOS, where home→store symlinks make the walk explode.

## Local workaround (implemented here)

- `fish/.config/fish/functions/claude.fish` — runs `command claude` with `HOME=$HOME/.claude-home`.
- `scripts/setup-claude-home.sh` — wires the isolated home: shared `~/.claude` (settings,
  rtk hook, skills, credentials, history), `~/.claude.json`, `~/.ssh`, `~/.kube`,
  `~/.config/rtk`, `~/.local/share/rtk` via symlinks; keeps the tiny `.cache/.npm/.rbenv` state.
- `~/.claude/settings.json` — user-scope `sandbox.filesystem.denyRead` backfill (literal
  absolute paths) so the real home's sensitive paths (`.aws`, `.gnupg`, sops rendered
  secrets, `~/.claude/.credentials.json`, nix state dirs, ...) stay denied even though `~`
  now resolves to the isolated home. Denies merge across settings scopes.
- `nixos/.nixos/pkgs/claude-code-latest.nix` — hand-pinned claude-code 2.1.281 (org minimum
  is 2.1.277; nixpkgs unstable still has 2.1.266).
- Result: 37.85s → 9.3s, and the `~/.*` deny correctly applies again (12 paths in the
  isolated home).
