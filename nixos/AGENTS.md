# NixOS / nix-darwin Configuration — Agent Guide

Modular flake-parts setup supporting three NixOS hosts and two nix-darwin (macOS) hosts.

| Host | System | Role |
|------|--------|------|
| `thinkpad-t480` | x86_64-linux | Primary laptop — Hyprland, NVIDIA PRIME, full desktop |
| `nixos-arm-vm` | aarch64-linux | ARM VM |
| `nixos-x86-vm` | x86_64-linux | x86 VM |
| `uw-mac-m1` | aarch64-darwin | Work MacBook M1 (`work.enable = true`) |
| `vitorf7-mac-m1` | aarch64-darwin | Personal MacBook M1 |

## The dendritic pattern

`flake.nix` passes `import-tree ./modules` directly to `flake-parts.lib.mkFlake` — **every `.nix` file under `modules/` is auto-imported as a flake-parts module**. There are no hand-maintained import lists.

Each module file registers itself into a shared registry:

- `flake.modules.nixos.<name>` — NixOS system modules
- `flake.modules.darwin.<name>` — nix-darwin system modules
- `flake.modules.homeManager.<name>` — home-manager user modules

A single file may populate more than one class (e.g. `git.nix` sets both `flake.modules.darwin.git` and `flake.modules.homeManager.git`). Host files under `modules/hosts/<name>/default.nix` pull from this registry by name.

## Layout

```
.nixos/
├── flake.nix                   Entry point — import-tree ./modules handed to flake-parts
├── modules/                    ~59 .nix files, all auto-imported; no aggregator files
│   ├── flake-modules-type.nix  Declares the flake.modules option type (repo scaffolding)
│   ├── options.nix             vitorf7.* option tree — shared across nixos and darwin classes
│   ├── packages.nix            Custom packages (perSystem block; non-conforming)
│   ├── hosts/                  Per-host module lists
│   │   ├── thinkpad-t480/      NixOS — default.nix + _hardware-configuration.nix
│   │   ├── nixos-arm-vm/       NixOS — default.nix only (hardware config must be generated)
│   │   ├── nixos-x86-vm/       NixOS — default.nix only
│   │   ├── uw-mac-m1/          nix-darwin — work.enable = true
│   │   └── vitorf7-mac-m1/     nix-darwin — work.enable = false (nordvpn instead)
│   └── ...                     Feature modules (see options.nix for flags)
├── pkgs/                       Custom derivations (go-latest, strongbox, tide-island, wiresteward)
├── secrets/                    Strongbox-encrypted — DO NOT READ
└── sops/                       SOPS age-encrypted secrets — DO NOT READ
```

## Custom options (`vitorf7.*`)

All feature toggles live under `vitorf7` in `modules/options.nix`, shared between nixos and darwin classes.

| Namespace | Gates |
|-----------|-------|
| `vitorf7.desktop.*` | Desktop env, Hyprland, Quickshell shells, Flatpak, gaming, WinBoat |
| `vitorf7.hardware.*` | NVIDIA PRIME, fingerprint (fprintd), QEMU guest |
| `vitorf7.networking.*` | NordVPN, GlobalProtect, Wiresteward WireGuard |
| `vitorf7.darwin.*` | macOS base, Homebrew, Aerospace+sketchybar, Colima, work-only items |
| `vitorf7.git.*` | Personal/work profile switching, sops-managed identities |

## Adding a module

1. Create `modules/<feature>.nix` — auto-imported by `import-tree`, no registration in `flake.nix`
2. In the file, set `flake.modules.<class>.<name>` to a `deferredModule` value
3. Add `self.modules.<class>.<name>` to the relevant host's `default.nix`

## Adding a host

**NixOS:** create `modules/hosts/<name>/default.nix` (nixosSystem call pulling from `self.modules.*`) and place `_hardware-configuration.nix` in the same directory (generated via `nixos-generate-config`).

**macOS:** create `modules/hosts/<name>/default.nix` (darwinSystem call) then run `scripts/initial_macos_setup.sh <name>` — records the flake host in `~/.config/nix-darwin-host` so `nrs` works thereafter.

## Deploying

```bash
# NixOS
sudo nixos-rebuild switch --flake .#<hostname>

# macOS
sudo darwin-rebuild switch --flake .#<hostname>
# or, once ~/.config/nix-darwin-host is written:
nrs
```

## Secrets — never read

**Do NOT read any file inside `secrets/` or `sops/` directories** (`.nixos/secrets/*`, `.nixos/sops/*`). These contain Strongbox- and SOPS-encrypted secrets and must never be accessed by an agent.
