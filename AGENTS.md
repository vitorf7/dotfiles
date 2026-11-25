# Dotfiles — Agent Guide

GNU Stow-based dotfiles repo for Linux and macOS.

## Structure

Each top-level directory (except `nixos/`, `scripts/`, `secrets/`, `configs/`, `bin/`) is a **Stow package** whose layout mirrors `$HOME`. Running `stow <package>` symlinks it in.

| Path         | Purpose                                            |
| ------------ | -------------------------------------------------- |
| `<package>/` | Stow package → symlinked to `$HOME`                |
| `nixos/`     | NixOS/nix-darwin Nix flake (see `nixos/AGENTS.md`) |
| `scripts/`   | One-shot setup and bootstrap scripts               |
| `bin/`       | User executables                                   |
| `configs/`   | Misc config blobs outside Stow                     |
| `secrets/`   | Encrypted secrets — **see rule below**             |

## Key packages

| Category    | Packages                                                   |
| ----------- | ---------------------------------------------------------- |
| Shell       | `fish/` (primary), `zsh/`                                  |
| Editor      | `neovim/` (submodule), `lunarvim/` (submodule), `ideavim/` |
| Terminal    | `ghostty/`, `alacritty/`, `wezterm/`                       |
| Multiplexer | `tmux/`                                                    |
| Git tooling | `git/`, `lazygit/`, `gh/`, `gh-dash/`                      |
| macOS WM    | `aerospace/`, `sketchybar/`, `yabai/`, `karabiner/`        |
| Linux WM    | `hyprland/`, `waybar/`, `rofi/`, `swaync/`                 |
| Qs shells   | `qs-slate/`, `dank-material-shell/`, `caelestia/`, `ambxst/` (symlinked by home-manager, not stowed) |
| Dev         | `k9s/`, `starship/`, `bat/`                                |

**Slate is its own login session and never reads `~/.config/hypr`.** Your personal Hyprland settings reach it through `qs-slate/.config/slate/hypr/*.lua` (Slate loads `env`, `variables`, then its own config, then `monitors`, `binds`, `rules`, `autostart`, `hyprland` — later wins). Those files `dofile` the session-agnostic modules from `hyprland/.config/hypr/modules/` (environment, monitors, monitor_manager, windowrules, input, clamshell) so there is one copy; `binds.lua` and `autostart.lua` are curated instead. Rules for editing them:

- **One owner per capability.** Don't bind or start in the Slate session what Slate already does (volume/media keys and OSD, wallpaper, idle/lock, polkit agent, power menu, notifications, tray watcher). Starting a second one gives duplicate pop-ups, or two polkit agents fighting over registration.
- **Binds stack, they don't replace.** A chord bound twice fires both actions, and key-name case doesn't matter (`ALT + J` and `ALT + j` are the same chord). To make yours win over one of Slate's, `hl.unbind(<chord>)` first (Slate binds digits as `code:10`..`code:19`, so unbind those spellings).
- Don't define a second submap named `resize`; enter Slate's.
- **Ghostty owns the Super+letter chords it sends to tmux/nvim** (`ghostty/.config/ghostty/config`: `super+j`, `super+k`, `super+t`, `super+d`, …). Slate binds many Super+letters globally, and Hyprland grabs a bound chord before any app sees it, so when you add a `super+…` keybind to Ghostty, add its chord to the "Ghostty owns" unbind list in `qs-slate/.config/slate/hypr/binds.lua`.

## Submodules

`neovim/.config/nvim`, `lunarvim/.config/lvim`, and `neovimold/.config/nvimold` are git submodules. Run `git submodule update --init --recursive` after cloning.

## NixOS / nix-darwin

See `nixos/AGENTS.md` for the full Nix flake guide.

## Claude Code on Linux (perf workaround)

`fish/.config/fish/functions/claude.fish` runs Claude Code wrapped with another layer of `bubblewrap`. Bubblewrapping `bubblewrap`. In other words before calling `claude` so that its internal `bubblewrap` tries to walk the `$HOME` dir etc, we construct our own home but set the problematic directories (ie. the deeply nested symlink directories in NixOS such as `~/.local/state/nix`, `~/.local/state/home-manager` and `~/.nix-defexpr`) with --tmpfs which mounts the directories as empty. This means `claude` then launches in the home directory with access to everything it normally does like `git`, `kubectl`, etc config but its `bwrap` (`bubblewrap`) will not have to walk through the NixOS directories because they are empty to it at that point. This massively sped up the usage of `claude` in Linux from unusable (30s on average to do anything) to usable (a few seconds like most other systems).

**Never leave a dot-prefixed symlink-to-directory at the top of `$HOME` (e.g. `~/.nixos`).** The work-managed Claude Code remote settings force `sandbox.enabled` with `denyRead: ["~/.*", ...]`; Claude Code expands that glob over `$HOME`'s top level and tmpfs-mounts every dot-entry *without resolving symlinks* (verified in 2.1.281), and bwrap refuses to mount on a symlink destination. Result: every sandboxed Bash call in Claude dies with `bwrap: Can't mount on symlink destination ~/.nixos`. That is why the nixos stow package's flake dir is `nix-config/` (not `.nixos/`): stowing it produces `~/nix-config`, which the `~/.*` deny glob never matches. Symlinked dot-*files* are fine (Claude resolves those before masking); `~/.nix-profile` (a symlink-to-dir created by Nix) only survives because the wrapper above tmpfs-hides its target, so it dangles inside Claude's view.

## RULE: never read secrets

**Do NOT read any file inside `secrets/` or any path matching `*/secrets/*` or `*/sops/*` anywhere in this repo.** These directories contain encrypted secrets (Strongbox / SOPS) and must never be accessed by an agent.
