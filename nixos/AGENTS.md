# NixOS / nix-darwin Configuration — Agent Guide

Modular flake-parts setup supporting four NixOS hosts and two nix-darwin (macOS) hosts.

| Host | System | Role |
|------|--------|------|
| `thinkpad-t480` | x86_64-linux | Primary laptop — Hyprland, NVIDIA PRIME, full desktop |
| `uw-thinkpad-x1` | x86_64-linux | Work laptop (ThinkPad X1 Carbon) — Hyprland, Intel-only, UW VPNs, no gaming |
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
│   │   ├── uw-thinkpad-x1/     NixOS — default.nix + placeholder _hardware-configuration.nix
│   │   ├── nixos-arm-vm/       NixOS — default.nix only (hardware config must be generated)
│   │   ├── nixos-x86-vm/       NixOS — default.nix only
│   │   ├── uw-mac-m1/          nix-darwin — work.enable = true
│   │   └── vitorf7-mac-m1/     nix-darwin — work.enable = false (nordvpn instead)
│   └── ...                     Feature modules (see options.nix for flags)
├── pkgs/                       Custom derivations (claude-code-latest, go-latest, strongbox, tide-island, wiresteward)
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

## Updating pinned custom packages

`nix flake update` only bumps the flake `inputs` in `flake.nix` — it does **not** touch the hand-pinned derivations under `pkgs/` (`strongbox`, `wiresteward`, `go-latest`, `tide-island`, `mouseless`, `claude-code-latest`). Those pin a `rev`/`tag`/`version` + `hash` by hand and only move when someone refreshes them.

The easiest way is the fish aliases in `fish/.config/fish/aliases.fish` (mirroring `nrs`):

- `nix-update-derivations` — refreshes `strongbox`, `wiresteward`, `tide-island`, and (on a Linux host) `mouseless` in one go.
- `nix-update-golatest` — runs `scripts/update-go.sh` for `go-latest`.
- `nix-update-claude` — runs `scripts/update-claude-code.sh` for `claude-code-latest`.

Then rebuild to pick up the change: `sudo darwin-rebuild switch --flake .#<host>` / `nrs` / `sudo nixos-rebuild switch --flake .#<hostname>`.

Details, if running things by hand:

- `strongbox`/`wiresteward` — standard `buildGoModule` + `fetchFromGitHub rec` shape: `nix-update strongbox --flake` / `nix-update wiresteward --flake`. If a `buildGoModule` update fails with `go.mod requires go >= X.Y.Z` during the `vendorHash` step, that's nixpkgs' own `go`/`go_1_26` lagging behind — run `nix flake update nixpkgs` first, then retry.
- `tide-island`/`mouseless` — `stdenv.mkDerivation`/`appimageTools.wrapAppImage` don't preserve the source position of `version`/`src` the way `nix-update --flake` needs, even when written as a self-referencing `rec` set — it crashes with `expected a set but found null: null`. Use the non-flake shim instead: `nix-update tide-island -f pkgs/nix-update-shim.nix --override-filename pkgs/tide-island.nix` (same pattern for `mouseless`, but `mouseless` has no darwin sources at all and needs to actually fetch a linux-only AppImage — run it from a Linux host, add `--system x86_64-linux`/`aarch64-linux` only if evaluating from Linux fails to resolve a platform key).
- `go-latest` — sourced from go.dev, not GitHub, and needs 3 platform hashes at once: run `scripts/update-go.sh` instead of `nix-update`.
- `claude-code-latest` — an override of nixpkgs' `claude-code` carrying its own release manifest, so `nix-update` can't see its version/src: run `scripts/update-claude-code.sh` instead (fetches the latest version + checksums from `downloads.claude.ai/claude-code-releases`). Keep it at or above the org's `minimumVersion` (currently v2.1.277) — nixpkgs unstable usually lags behind it.
- `nix-update` (`nix run nixpkgs#nix-update --` if not on `PATH`, or via `nix develop` — see `modules/packages.nix`'s `devShells.default`) never builds anything by default (`--build` is opt-in), so these are all fast, hash-only updates — build/verify separately via `nrs`.

**If any of the above stops partway through** (a real build failure, a network hiccup, etc.), it can leave the `.nix` file half-updated — e.g. `version` bumped but `vendorHash`/`hash` still the old value. Check `git diff pkgs/` after a failed run and revert by hand if so, rather than leaving a derivation with mismatched version/hash pairs.

The `overrideAttrs` patches in `modules/nix-base.nix` (`throttled`) and `modules/dank-material-shell.nix` ride whatever version `nix flake update` brings in — no separate update step, but re-check the patch still applies after a big nixpkgs/DMS bump.

## Secrets — never read

**Do NOT read any file inside `secrets/` or `sops/` directories** (`.nixos/secrets/*`, `.nixos/sops/*`). These contain Strongbox- and SOPS-encrypted secrets and must never be accessed by an agent.
