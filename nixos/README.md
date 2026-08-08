# NixOS / nix-darwin Configuration

Modular flake-parts setup supporting three NixOS hosts and two nix-darwin (macOS) hosts.

| Host | System | Features |
|------|--------|----------|
| `thinkpad-t480` | x86_64-linux | desktop, hyprland, caelestia-shell, gaming, winboat, flatpak, fingerprint, nvidia, nordvpn, globalprotect, wiresteward |
| `nixos-arm-vm` | aarch64-linux | desktop, hyprland, quickshell, vm |
| `nixos-x86-vm` | x86_64-linux | hyprland, quickshell, vm |
| `uw-mac-m1` | aarch64-darwin | UW work MacBook Pro (M1 Pro) — homebrew, aerospace, work.enable |
| `vitorf7-mac-m1` | aarch64-darwin | Personal MacBook (M1) — homebrew, aerospace, nordvpn (work.enable = false) |

## The dendritic pattern

This flake follows the ["dendritic" flake-parts pattern](https://github.com/mightyiam/dendritic):
there is no hand-maintained list of module imports anywhere. Instead, `flake.nix` hands
[`import-tree`](https://github.com/vic/import-tree) the `modules/` directory, which walks it
recursively and imports **every** `.nix` file it finds as a flake-parts module:

```nix
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
    (import-tree ./modules);
```

Each module file registers itself into a shared registry — `flake.modules.<class>.<name>` —
where `<class>` is `nixos`, `darwin`, or `homeManager`. A single file can populate more than
one class (e.g. `git.nix` sets both `flake.modules.darwin.git` and
`flake.modules.homeManager.git`). Host files under `modules/hosts/<name>/` then pick, by name,
exactly which registered modules they want — adding a new module is just adding a `.nix` file
under `modules/`; wiring it into a host is a one-line addition to that host's module list.

## Fresh install (one-liner)

Run this on the target machine right after a minimal NixOS install. It clones the
dotfiles, copies the hardware config, and builds the flake — reboot to activate.

```bash
bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_nixos_setup.sh) <hostname>
```

Example:

```bash
bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_nixos_setup.sh) thinkpad-t480
```

> **Prerequisite:** run `sudo nixos-generate-config` first if
> `/etc/nixos/hardware-configuration.nix` doesn't exist yet.

## Deploying (subsequent rebuilds)

```bash
# From inside the VM or machine:
sudo nixos-rebuild switch --flake .#<hostname>

# Example:
sudo nixos-rebuild switch --flake .#nixos-arm-vm
```

### Secrets

Two secret-management mechanisms coexist:

**strongbox** — still covers `nixos/.nixos/secrets/wiresteward-secrets.nix`, encrypted at rest
with [strongbox](https://github.com/uw-labs/strongbox) — the same tool/key already used
elsewhere in this dotfiles repo — and decrypts automatically on `git clone`/`checkout`/`pull`.
Before building a host with wiresteward enabled, make sure this machine already has:

1. `strongbox` installed
2. The private keyring in place (same one used for the rest of this repo)
3. `scripts/gitconfig.sh` run once, to wire up the git filter

If those aren't in place yet, `nixos/.nixos/secrets/*` will contain ciphertext instead of
usable Nix values. Edit the file with real values before relying on wiresteward DNS.

**sops-nix** — covers everything else: git identities (`sops/git/{personal,work}.yaml`),
sketchybar weather vars (`sops/darwin/weather_vars.lua`), the shared fish private config
(`sops/shared/private_config.fish`), and the wiresteward runtime config
(`sops/nixos/wiresteward-config.json`). Decryption needs an age key present at
`/etc/sops/age/keys.txt` (system-level secrets, e.g. wiresteward) or
`~/.config/sops/age/keys.txt` (home-manager secrets, e.g. git identity) — provision that key
out of band before the first build that enables secrets.nix's consumers.

---

## Fresh install (macOS, one-liner)

Run this on a fresh macOS machine. It installs Xcode CLT/Homebrew/Determinate Nix
if absent, clones dotfiles, decrypts strongbox secrets, stows `~/.nixos`, and does
the first nix-darwin activation.

```bash
bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_macos_setup.sh) <hostname>
```

Example:

```bash
bash <(curl -sL https://raw.githubusercontent.com/vitorf7/dotfiles/master/scripts/initial_macos_setup.sh) uw-mac-m1
```

> **Prerequisite:** `~/.strongbox_keyring` must already be in place (retrieve from
> 1Password) — three configs (fish, k9s, sketchybar) pull secrets that need it. A sops-nix age
> key must also be provisioned (see Secrets, above) for git identity and sketchybar weather vars.

The script records the flake host in `~/.config/nix-darwin-host` as its last step,
so subsequent `nrs` (no args) works without relying on the system hostname — macOS
hostname can't be trusted for this on MDM-managed machines (Jamf/Kandji can reassert
an asset-tag-based ComputerName at any time).

## Deploying (macOS, subsequent rebuilds)

```bash
sudo darwin-rebuild switch --flake .#<hostname>

# Or, once ~/.config/nix-darwin-host is written, just:
nrs
```

---

## Manual steps required before first deploy

### 1. Hardware configuration (per machine)

Each NixOS host directory has (or needs) a real `_hardware-configuration.nix`. Generate it on
the target machine:

```bash
nixos-generate-config --show-hardware-config > _hardware-configuration.nix
# then move it to modules/hosts/<hostname>/_hardware-configuration.nix
```

`nixos-arm-vm` and `nixos-x86-vm` do not ship one in the repo yet — this must be generated on
the actual VM before first deploy.

### 2. NVIDIA bus IDs (T480 only)

On the ThinkPad T480, run:

```bash
lspci | grep -E 'VGA|3D'
```

Update `prime.intelBusId` and `prime.nvidiaBusId` in `.nixos/modules/nvidia.nix` to match the
output (format: `PCI:bus:device:function`).

---

## Custom options (`vitorf7.*` namespace)

All feature toggles live under `vitorf7` in `modules/options.nix`, shared verbatim between the
`nixos` and `darwin` module classes.

| Option | Default | Gates |
|--------|---------|-------|
| `vitorf7.username` | *(required)* | Primary user account name for the host — no default, every host must set it |
| `vitorf7.desktop.enable` | false | General desktop environment (browser, fonts, themes, audio, 1Password) |
| `vitorf7.desktop.hyprland.enable` | false | Hyprland Wayland ecosystem, PipeWire, Bluetooth, XDG portals |
| `vitorf7.desktop.quickshell.enable` | false | Quickshell framework + common shell runtime deps |
| `vitorf7.desktop.qs_brain_shell.enable` | false | Brain_Shell Quickshell config (requires `quickshell.enable`) |
| `vitorf7.desktop.ambxst.enable` | false | Ambxst Quickshell shell |
| `vitorf7.desktop.tide_island.enable` | false | Tide Island Dynamic Island for Hyprland (Quickshell-based) |
| `vitorf7.desktop.caelestia_shell.enable` | false | Caelestia Shell Quickshell config |
| `vitorf7.desktop.flatpak.enable` | false | Declarative Flatpak via nix-flatpak |
| `vitorf7.desktop.gaming.enable` | false | Gaming (Steam, Lutris, emulators) |
| `vitorf7.desktop.winboat.enable` | false | WinBoat — Windows apps on Linux via Docker + KVM + RemoteApp |
| `vitorf7.hardware.nvidia.enable` | false | NVIDIA PRIME offload (legacy_535) |
| `vitorf7.hardware.fingerprint.enable` | false | fprintd + PAM hooks (login, sudo, hyprlock) |
| `vitorf7.hardware.vm.enable` | false | QEMU guest + SPICE agent |
| `vitorf7.networking.nordvpn.enable` | false | NordVPN client (CLI + GUI) with systemd/launchd daemon |
| `vitorf7.networking.globalprotect.enable` | false | GlobalProtect VPN client (gpclient + gpgui), via GlobalProtect-openconnect |
| `vitorf7.networking.wiresteward.enable` | false | Wiresteward WireGuard agent (dev/prod × AWS/GCP/Merit clusters) |
| `vitorf7.darwin.enable` | false | macOS (nix-darwin) base configuration |
| `vitorf7.darwin.homebrew.enable` | false | Declarative Homebrew (taps, casks, mas apps) |
| `vitorf7.darwin.aerospace.enable` | false | Aerospace WM + sketchybar + jankyborders stack |
| `vitorf7.darwin.colima.enable` | false | Colima container runtime as a launchd user agent |
| `vitorf7.darwin.work.enable` | false | Work-only items (Okta Verify); `!work.enable` adds nordvpn instead |
| `vitorf7.git.defaultProfile` | `"personal"` | Which git profile (`personal`/`work`) provides the top-level `[user]` identity |
| `vitorf7.git.personal.enable` | false | Personal git profile (sops-managed identity) |
| `vitorf7.git.personal.directories` | `["~/configfiles/"]` | Directories where the personal `includeIf` applies |
| `vitorf7.git.work.enable` | false | Work git profile (sops-managed identity) |
| `vitorf7.git.work.directories` | `[]` | Directories where the work `includeIf` applies |

---

## Flake inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | nixos/nixpkgs `nixos-unstable` | Main package set |
| `flake-parts` | hercules-ci/flake-parts | Flake structure |
| `import-tree` | vic/import-tree | Auto-imports every `.nix` file under `modules/` — the dendritic mechanism |
| `home-manager` | nix-community/home-manager `master` | User environment |
| `nix-darwin` | LnL7/nix-darwin `master` | macOS system configuration |
| `sops-nix` | Mic92/sops-nix | Secrets (age-encrypted, alongside strongbox) |
| `zen-browser` | youwen5/zen-browser-flake | Zen browser package |
| `brain-shell` | Brainitech/Brain_Shell `dev` | Brain_Shell Quickshell config |
| `ambxst` | Axenide/Ambxst | Ambxst shell |
| `caelestia-shell` | caelestia-dots/shell | Caelestia Shell Quickshell config |
| `hyprmod` | vitorf7/hyprmod `nix-flake` | hyprmod GTK4 Hyprland settings app (own flake now, supersedes `pkgs/hyprmod.nix`) |
| `nixos-hardware` | NixOS/nixos-hardware `master` | T480 hardware quirks |
| `nix-flatpak` | gmodena/nix-flatpak | Declarative Flatpak management |
| `nixos-06cb-009a-fingerprint-sensor` | ahbnr/nixos-06cb-009a-fingerprint-sensor `ref=24.11` | T480 fingerprint sensor driver — deliberately **not** following `nixpkgs` (its python-validity package needs 24.11 build conventions) |
| `globalprotect-openconnect` | yuezk/GlobalProtect-openconnect | GlobalProtect VPN client — deliberately **not** following `nixpkgs` (specific Rust toolchain requirements, bundles the proprietary gpgui binary) |

---

## Module structure

```
.nixos/
├── flake.nix                        Entry point — hands `import-tree ./modules` to flake-parts.mkFlake
├── modules/                         Flat: every .nix file here is auto-imported, no aggregator files
│   ├── flake-modules-type.nix       Declares the `flake.modules` / `flake.darwinConfigurations` options
│   │                                (repo-local scaffolding the registry convention depends on)
│   ├── options.nix                  Shared vitorf7.* option tree — assigned to both
│   │                                flake.modules.nixos.options and flake.modules.darwin.options
│   ├── packages.nix                 The one non-conforming module: plain perSystem block building
│   │                                custom packages (hyprmod, tide-island, go-latest, strongbox)
│   ├── nix-base.nix                 flake.modules.nixos.nix-base — always-on nix.settings, nix-ld, overlays
│   ├── boot.nix, locale.nix,
│   │   users.nix, power.nix,
│   │   webcam.nix, networking.nix   Always-on NixOS system modules
│   ├── nvidia.nix, fingerprint.nix,
│   │   vm.nix, flatpak.nix,
│   │   gaming.nix, winboat.nix,
│   │   globalprotect.nix,
│   │   wiresteward.nix, nordvpn.nix Flag-gated NixOS system modules (lib.mkIf config.vitorf7.*)
│   ├── hyprland.nix, quickshell.nix,
│   │   ambxst.nix, caelestia-shell.nix,
│   │   tide-island.nix,
│   │   qs-brain-shell.nix           Desktop-shell modules, each populating both nixos + homeManager
│   │                                (or homeManager only) classes
│   ├── darwin-system.nix,
│   │   darwin-defaults.nix,
│   │   darwin-homebrew.nix,
│   │   darwin-packages.nix,
│   │   darwin-symlinks.nix          Darwin-only system/home modules
│   ├── git.nix, secrets.nix         Dual-class examples: one file sets both
│   │                                flake.modules.darwin/nixos.X and flake.modules.homeManager.X
│   ├── core.nix, shell.nix, dev.nix,
│   │   editor.nix, desktop.nix,
│   │   browsers.nix, media.nix,
│   │   communication.nix, ai.nix,
│   │   ghostty.nix, kitty.nix,
│   │   alacritty.nix, vicinae.nix,
│   │   aerospace.nix, sketchybar.nix,
│   │   kubernetes.nix, docker.nix,
│   │   databases.nix, ides.nix,
│   │   input.nix, macos-utils.nix,
│   │   fonts.nix, onepassword.nix   Home-manager modules — see `ls modules/` for the full ~56-file catalog
│   └── hosts/
│       ├── thinkpad-t480/
│       │   ├── default.nix          nixosSystem call — module list pulled from self.modules.nixos.*
│       │   │                        and self.modules.homeManager.*
│       │   └── _hardware-configuration.nix
│       ├── nixos-arm-vm/default.nix
│       ├── nixos-x86-vm/default.nix
│       ├── uw-mac-m1/default.nix    darwinSystem call, work.enable = true
│       └── vitorf7-mac-m1/default.nix   darwinSystem call, work.enable = false (nordvpn instead of Okta Verify)
├── pkgs/
│   ├── go-latest.nix                Custom derivation — latest Go toolchain, wired via packages.nix
│   ├── strongbox.nix                Custom derivation — strongbox v2.1.0, wired via packages.nix
│   ├── tide-island.nix              Custom derivation — Tide Island, wired via packages.nix
│   ├── wiresteward.nix              Custom derivation — consumed directly from modules/wiresteward.nix
│   ├── hyprmod.nix                  Superseded — hyprmod now comes from its own flake input; dead code
│   └── mouseless.nix                Not wired into any module — Mouseless is installed via Flatpak instead
├── secrets/                          strongbox-encrypted (wiresteward-secrets.nix)
└── sops/                             sops-nix age-encrypted (git identities, weather vars, wiresteward config)
```

## Adding a new host (NixOS)

1. Create `modules/hosts/<name>/default.nix` following the pattern in
   `modules/hosts/thinkpad-t480/default.nix`: a plain `{ inputs, self, ... }:` file that sets
   `flake.nixosConfigurations.<name> = inputs.nixpkgs.lib.nixosSystem { modules = [ ... ]; };`,
   pulling in `self.modules.nixos.options`, any always-on/flag-gated modules by name from
   `self.modules.nixos.*`, and a `home-manager.users.<user>.imports` list from
   `self.modules.homeManager.*`. There is nothing to register in `flake.nix` — the file is
   auto-discovered by `import-tree`.
2. Run `nixos-generate-config` on the machine and place `_hardware-configuration.nix` in the
   same directory.
3. Set the relevant `vitorf7.*` flags and `system.stateVersion` in the host-identity block.

## Adding a new host (macOS / nix-darwin)

1. Create `modules/hosts/<name>/default.nix` following the pattern in
   `modules/hosts/uw-mac-m1/default.nix`: sets
   `flake.darwinConfigurations.<name> = inputs.nix-darwin.lib.darwinSystem { modules = [ ... ]; };`,
   pulling in `self.modules.darwin.options`, host identity (`networking.hostName`/`computerName`,
   `vitorf7.username`, `vitorf7.darwin.*` flags — `work.enable = false` for a personal machine
   skips Okta Verify and adds nordvpn instead), the relevant `self.modules.darwin.*` system
   modules, and a `home-manager.users.<user>.imports` list from `self.modules.homeManager.*`.
2. Run `./scripts/initial_macos_setup.sh <name>` on the target machine — it records the flake
   host in `~/.config/nix-darwin-host` as its last step, so subsequent `nrs` works with no args.
