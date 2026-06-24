# NixOS Configuration

Modular flake-parts setup supporting three hosts and a future macOS stub.

| Host | System | Notes |
|------|--------|-------|
| `thinkpad-t480` | x86_64-linux | Physical machine, NVIDIA PRIME + fingerprint |
| `nixos-arm-vm` | aarch64-linux | ARM VM (QEMU/SPICE) |
| `nixos-x86-vm` | x86_64-linux | x86 VM (QEMU/SPICE) |
| `darwin-m1` | aarch64-darwin | Pending nix-darwin integration |

## Deploying

```bash
# From inside the VM or machine:
sudo nixos-rebuild switch --flake .#<hostname>

# Example:
sudo nixos-rebuild switch --flake .#nixos-arm-vm
```

---

## Manual steps required before first deploy

### 1. Hyprmod hash

The `pkgs/hyprmod.nix` derivation has a placeholder hash. Run this on a Linux machine with Nix to get the real one:

```bash
nix-prefetch-url --unpack \
  https://github.com/BlueManCZ/hyprmod/archive/refs/tags/v0.3.0.tar.gz
```

Paste the `sha256-...` output into the `hash` field in `.nixos/pkgs/hyprmod.nix`.

Once the hash is fixed and the ARM build is verified, remove this line from `hyprmod.nix`:
```nix
broken = stdenv.isAarch64;
```

### 2. Mouseless hash

Check the [mouseless releases page](https://github.com/elitek7/mouseless/releases) for the latest Linux AppImage. Update `.nixos/pkgs/mouseless.nix` with:
- The correct `version`
- The correct `url` (matching the release asset filename)
- The real `hash` (get it the same way as hyprmod above)

### 3. Hardware configuration (per machine)

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
│   ├── hyprmod.nix            Custom derivation — needs real hash
│   └── mouseless.nix          Custom derivation — needs real hash + URL
├── modules/
│   ├── options.nix            Custom option declarations
│   ├── system/
│   │   ├── base-system.nix    Shared system config (boot, locale, user)
│   │   ├── audio.nix          PipeWire (active when hyprland.enable)
│   │   ├── bluetooth.nix      Bluetooth + blueman (active when hyprland.enable)
│   │   ├── display.nix        GDM + Hyprland session (active when hyprland.enable)
│   │   ├── fingerprint.nix    fprintd + PAM (active when fingerprint.enable)
│   │   └── nvidia-hybrid.nix  NVIDIA PRIME offload (active when nvidia.enable)
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
