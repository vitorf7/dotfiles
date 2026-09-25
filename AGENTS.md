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
| Dev         | `k9s/`, `starship/`, `bat/`                                |

## Submodules

`neovim/.config/nvim`, `lunarvim/.config/lvim`, and `neovimold/.config/nvimold` are git submodules. Run `git submodule update --init --recursive` after cloning.

## NixOS / nix-darwin

See `nixos/AGENTS.md` for the full Nix flake guide.

## Claude Code on Linux (perf workaround)

`fish/.config/fish/functions/claude.fish` runs Claude Code wrapped with another layer of `bubblewrap`. Bubblewrapping `bubblewrap`. In other words before calling `claude` so that its internal `bubblewrap` tries to walk the `$HOME` dir etc, we construct our own home but set the problematic directories (ie. the deeply nested symlink directories in NixOS such as `~/.local/state/nix`, `~/.local/state/home-manager` and `~/.nix-defexpr`) with --tmpfs which mounts the directories as empty. This means `claude` then launches in the home directory with access to everything it normally does like `git`, `kubectl`, etc config but its `bwrap` (`bubblewrap`) will not have to walk through the NixOS directories because they are empty to it at that point. This massively sped up the usage of `claude` in Linux from unusable (30s on average to do anything) to usable (a few seconds like most other systems).

## RULE: never read secrets

**Do NOT read any file inside `secrets/` or any path matching `*/secrets/*` or `*/sops/*` anywhere in this repo.** These directories contain encrypted secrets (Strongbox / SOPS) and must never be accessed by an agent.
