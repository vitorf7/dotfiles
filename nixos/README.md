# NixOS Configuration

Modular flake-parts setup supporting three hosts and a future macOS stub.

| Host | System | Features |
|------|--------|----------|
| `thinkpad-t480` | x86_64-linux | desktop, hyprland, ambxst, flatpak, fingerprint, nvidia |
| `nixos-arm-vm` | aarch64-linux | desktop, hyprland, qs_brain_shell, vm |
| `nixos-x86-vm` | x86_64-linux | hyprland, qs_brain_shell, vm |
| `darwin-m1` | aarch64-darwin | Pending nix-darwin integration |

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

---

## Manual steps required before first deploy

### 1. Hardware configuration (per machine)

Each host directory has a placeholder `hardware-configuration.nix`. Replace it with the real one generated on the target machine:

```bash
nixos-generate-config --show-hardware-config > hardware-configuration.nix
# then move it to .nixos/hosts/<hostname>/hardware-configuration.nix
```

### 2. NVIDIA bus IDs (T480 only)

On the ThinkPad T480, run:

```bash
lspci | grep -E 'VGA|3D'
```

Update `intelBusId` and `nvidiaBusId` in `.nixos/modules/system/nvidia-hybrid.nix` to match the output (format: `PCI:bus:device:function`).

---

## Custom options (`vitorf7.*` namespace)

All feature toggles live under `vitorf7` in `modules/options.nix`.

| Option | Default | Gates |
|--------|---------|-------|
| `vitorf7.desktop.enable` | false | Zen browser, fonts, SSH agent, audio tools, theming, GDM |
| `vitorf7.desktop.hyprland.enable` | false | Hyprland WM, PipeWire, Bluetooth, XDG portals |
| `vitorf7.desktop.quickshell.enable` | false | Quickshell framework + upower |
| `vitorf7.desktop.qs_brain_shell.enable` | false | Brain_Shell Quickshell config (requires quickshell) |
| `vitorf7.desktop.ambxst.enable` | false | Ambxst shell (requires hyprland) |
| `vitorf7.desktop.flatpak.enable` | false | Declarative Flatpak via nix-flatpak |
| `vitorf7.hardware.nvidia.enable` | false | NVIDIA PRIME offload (MX150/legacy_535) |
| `vitorf7.hardware.fingerprint.enable` | false | fprintd + PAM hooks (login, sudo, hyprlock) |
| `vitorf7.hardware.vm.enable` | false | QEMU guest + SPICE agent |

---

## Flake inputs

| Input | Source | Purpose |
|-------|--------|---------|
| `nixpkgs` | nixos/nixpkgs `nixos-unstable` | Main package set |
| `flake-parts` | hercules-ci/flake-parts | Flake structure |
| `home-manager` | nix-community/home-manager `master` | User environment |
| `zen-browser` | youwen5/zen-browser-flake | Zen browser package |
| `brain-shell` | Brainitech/Brain_Shell `dev` | Brain_Shell Quickshell config |
| `ambxst` | Axenide/Ambxst | Ambxst shell |
| `nixos-hardware` | NixOS/nixos-hardware `master` | T480 hardware quirks |
| `nix-flatpak` | gmodena/nix-flatpak | Declarative Flatpak management |
| `nix-darwin` | (commented out) | Future macOS M1 support |

---

## Module structure

```
.nixos/
├── flake.nix                        Entry point (flake-parts)
├── lib/
│   └── mkHost.nix                   Host builder helper (reduces boilerplate)
├── pkgs/
│   ├── hyprmod.nix                  Custom derivation — hyprmod v0.4.0 (GTK4 Hyprland settings app)
│   └── mouseless.nix                Custom derivation — Mouseless v1.0.0-preview.3 (AppImage)
├── modules/
│   ├── options.nix                  Custom option declarations (vitorf7.* namespace)
│   ├── system/
│   │   ├── base-system.nix          Umbrella that imports all system modules
│   │   ├── audio.nix                PipeWire + WirePlumber (active when hyprland.enable)
│   │   ├── bluetooth.nix            Bluetooth + blueman (active when hyprland.enable)
│   │   ├── boot.nix                 GRUB EFI bootloader
│   │   ├── display.nix              GDM + GNOME session (active when desktop.enable)
│   │   ├── fingerprint.nix          fprintd + PAM hooks (active when fingerprint.enable)
│   │   ├── flatpak.nix              nix-flatpak declarative Flatpak (active when flatpak.enable)
│   │   ├── hyprland.nix             Hyprland + XWayland + XDG portals (active when hyprland.enable)
│   │   ├── locale.nix               Timezone (Europe/London) + en_GB locale
│   │   ├── networking.nix           NetworkManager
│   │   ├── nvidia-hybrid.nix        NVIDIA PRIME offload, legacy_535 driver (active when nvidia.enable)
│   │   ├── power.nix                zram swap (50% RAM, zstd) + lid switch behaviour
│   │   ├── quickshell.nix           upower service (active when quickshell.enable)
│   │   ├── qs_brain_shell.nix       Brain_Shell upstream module (active when qs_brain_shell.enable)
│   │   ├── security.nix             1Password CLI + GUI + polkit (active when desktop.enable)
│   │   ├── ambxst.nix               Ambxst upstream module (active when ambxst.enable)
│   │   ├── users.nix                User vitorf7, fish shell, groups
│   │   ├── vm.nix                   QEMU guest + SPICE agent (active when vm.enable)
│   │   └── webcam.nix               v4l2loopback virtual camera (OBS Cam, always active)
│   └── home/
│       ├── default.nix              Home-manager entry point for vitorf7
│       ├── base-home.nix            Legacy shim → redirects to default.nix
│       ├── core.nix                 Shell, editor, CLI tools + dotfile symlinks (always active)
│       ├── desktop.nix              SSH agent, Zen browser, fonts, audio tools (active when desktop.enable)
│       ├── dev.nix                  k9s, lazygit, Node.js, Go, Rust, opencode (always active)
│       ├── hyprland.nix             Hyprland ecosystem packages + config symlinks (active when hyprland.enable)
│       ├── theming.nix              Rose Pine GTK/Qt/cursor theming (active when desktop.enable)
│       ├── quickshell.nix           Quickshell + playerctl, cava, brightnessctl (active when quickshell.enable)
│       ├── qs_brain_shell.nix       Assertion check only — packages handled by upstream module (active when qs_brain_shell.enable)
│       └── ambxst.nix               Ambxst config symlinks (active when ambxst.enable)
└── hosts/
    ├── thinkpad-t480/
    │   ├── configuration.nix
    │   └── hardware-configuration.nix
    ├── nixos-arm-vm/
    │   └── configuration.nix
    └── nixos-x86-vm/
        └── configuration.nix
```

## Adding a new host

1. Create `hosts/<name>/configuration.nix` — set the hostname and enable the relevant options
2. Run `nixos-generate-config` on the machine and place `hardware-configuration.nix` in the same dir
3. Add the host to `flake.nix`:
   ```nix
   <name> = mkHost { system = "<arch>-linux"; host = "<name>"; };
   ```
