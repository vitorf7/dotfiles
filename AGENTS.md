# Dotfiles — Agent Guide

GNU Stow-based dotfiles repo for Linux and macOS.

## Structure

Each top-level directory (except `nixos/`, `scripts/`, `secrets/`, `configs/`, `bin/`) is a **Stow package** whose layout mirrors `$HOME`. Running `stow <package>` symlinks it in.

| Path | Purpose |
|------|---------|
| `<package>/` | Stow package → symlinked to `$HOME` |
| `nixos/` | NixOS/nix-darwin Nix flake (see `nixos/AGENTS.md`) |
| `scripts/` | One-shot setup and bootstrap scripts |
| `bin/` | User executables |
| `configs/` | Misc config blobs outside Stow |
| `secrets/` | Encrypted secrets — **see rule below** |

## Key packages

| Category | Packages |
|----------|---------|
| Shell | `fish/` (primary), `zsh/` |
| Editor | `neovim/` (submodule), `lunarvim/` (submodule), `ideavim/` |
| Terminal | `ghostty/`, `alacritty/`, `wezterm/` |
| Multiplexer | `tmux/` |
| Git tooling | `git/`, `lazygit/`, `gh/`, `gh-dash/` |
| macOS WM | `aerospace/`, `sketchybar/`, `yabai/`, `karabiner/` |
| Linux WM | `hyprland/`, `waybar/`, `rofi/`, `swaync/` |
| Dev | `k9s/`, `starship/`, `bat/` |

## Submodules

`neovim/.config/nvim`, `lunarvim/.config/lvim`, and `neovimold/.config/nvimold` are git submodules. Run `git submodule update --init --recursive` after cloning.

## NixOS / nix-darwin

See `nixos/AGENTS.md` for the full Nix flake guide.

## RULE: never read secrets

**Do NOT read any file inside `secrets/` or any path matching `*/secrets/*` or `*/sops/*` anywhere in this repo.** These directories contain encrypted secrets (Strongbox / SOPS) and must never be accessed by an agent.
