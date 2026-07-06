# NixOS Configuration

Modular flake-parts setup supporting three hosts and a future macOS stub.

| Host | System | Notes |
|------|--------|-------|
| `thinkpad-t480` | x86_64-linux | Physical machine, NVIDIA PRIME + fingerprint |
| `nixos-arm-vm` | aarch64-linux | ARM VM (QEMU/SPICE) |
| `nixos-x86-vm` | x86_64-linux | x86 VM (QEMU/SPICE) |
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

### 4. NVIDIA bus IDs (T480 only)

On the ThinkPad T480, run:

```bash
lspci | grep -E 'VGA|3D'
```

Update `intelBusId` and `nvidiaBusId` in `.nixos/modules/system/nvidia-hybrid.nix` to match the output (format: `PCI:bus:device:function`).

### 5. GTK theme

`modules/home/theming.nix` installs `papirus-icon-theme` and `nwg-look` but leaves the GTK theme package to you. Add your preferred theme to the `home.packages` list there, e.g.:

```nix
# rose-pine (check nixpkgs for exact attribute name)
rose-pine-gtk-theme
# or catppuccin
catppuccin-gtk
```

Then set `gtk.theme.name` and `gtk.theme.package` in the same file.

---

## Module structure

```
.nixos/
├── flake.nix                  Entry point
├── lib/
│   └── mkHost.nix             Host builder helper (reduces boilerplate)
├── pkgs/
│   ├── hyprmod.nix            Custom derivation — needs real hash (see step 1 above)
│   └── mouseless.nix          Custom derivation — hashes baked in for v1.0.0-preview.3
├── modules/
│   ├── options.nix            Custom option declarations
│   ├── system/
│   │   ├── base-system.nix    Shared system config (boot, locale, user)
│   │   ├── audio.nix          PipeWire (active when hyprland.enable)
│   │   ├── bluetooth.nix      Bluetooth + blueman (active when hyprland.enable)
│   │   ├── display.nix        GDM + Hyprland session (active when hyprland.enable)
│   │   ├── fingerprint.nix    fprintd + PAM (active when fingerprint.enable)
│   │   ├── nvidia-hybrid.nix  NVIDIA PRIME offload (active when nvidia.enable)
│   │   └── vm.nix             QEMU guest + SPICE agent (active when vm.enable)
│   └── home/
│       ├── default.nix        Home-manager entry point
│       ├── core.nix           Shell, editor, CLI tools + dotfile symlinks
│       ├── desktop.nix        Hyprland ecosystem (active when hyprland.enable)
│       ├── theming.nix        GTK/Qt theming (active when hyprland.enable)
│       └── dev.nix            k9s, lazygit, language runtimes
└── hosts/
    ├── thinkpad-t480/
    ├── nixos-arm-vm/
    └── nixos-x86-vm/
```

## Adding a new host

1. Create `hosts/<name>/configuration.nix` — set the hostname and enable the relevant options
2. Run `nixos-generate-config` on the machine and place `hardware-configuration.nix` in the same dir
3. Add the host to `flake.nix`:
   ```nix
   <name> = mkHost { system = "<arch>-linux"; host = "<name>"; };
   ```
