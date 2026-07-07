# Understanding My NixOS Configuration — A Guided Tour

> This document explains the NixOS setup in `nixos/.nixos/` from first principles.
> It assumes you know Linux but have little to no prior Nix experience.
> All file paths are relative to `nixos/.nixos/` unless stated otherwise.

---

## Table of Contents

1. [Quick Reference Glossary](#0-quick-reference-glossary)
2. [The Big Picture](#1-the-big-picture)
3. [Nix the Language — Just Enough](#2-nix-the-language--just-enough)
4. [The Store and Derivations](#3-the-store-and-derivations)
5. [Flakes — the Project Container](#4-flakes--the-project-container)
6. [The Module System](#5-the-module-system)
7. [Layer-by-Layer Walkthrough](#6-layer-by-layer-walkthrough)
8. [Custom Patterns](#7-custom-patterns)
9. [Full Trace: The NVIDIA Feature Flag](#8-full-trace-the-nvidia-feature-flag)
10. [Practical Reference](#9-practical-reference)
11. [What Isn't Here Yet](#10-what-isnt-here-yet)

---

## 0. Quick Reference Glossary

| Term | Definition |
|------|-----------|
| **Attribute set** | Nix's fundamental key-value data structure. `{ foo = "bar"; baz = 42; }` — like a JSON object, but the language's native type. |
| **Derivation** | A build recipe stored in `/nix/store/`. Describes what source code, build tools, and commands produce a specific package. The output path is determined entirely by the inputs, so it is perfectly reproducible. |
| **Flake** | A standardised Nix project format. Has a `flake.nix` with `inputs` (pinned external sources) and `outputs` (packages, NixOS configs, etc.). Version-locked by `flake.lock`. |
| **flake-parts** | A library (`github:hercules-ci/flake-parts`) that splits a flake's `outputs` into composable modules, one of which can vary per system architecture. |
| **flake.lock** | Auto-generated file that records the exact git commit hash and content hash of every flake input. Makes builds reproducible. Never edit by hand. |
| **GDM** | GNOME Display Manager — the graphical login screen. This config uses it even with Hyprland as the window manager. |
| **Home Manager** | A NixOS module (and standalone tool) that manages your *user-level* environment — dotfiles, user packages, shell configuration — declaratively. |
| **lib.mkDefault** | Sets a config value at low priority (1000). Can be overridden by a plain assignment (priority 100) or `lib.mkForce`. |
| **lib.mkEnableOption** | A nixpkgs helper that creates a boolean `enable` option defaulting to `false`. Used in `modules/options.nix` for all feature flags. |
| **lib.mkForce** | Sets a config value at the highest priority, overriding everything else. |
| **lib.mkIf** | Conditionally applies a config block. `lib.mkIf condition { ... }` — the block only evaluates when `condition` is true. |
| **lib.mkOverride N** | Sets a value at explicit priority `N`. Lower N = higher precedence. Plain assignment = 100, `mkDefault` = 1000, `mkForce` = 50. |
| **mkHost** | A custom helper function in `lib/mkHost.nix` that wraps `nixpkgs.lib.nixosSystem` to remove per-host boilerplate. |
| **Module** | A `.nix` file that follows the `{ config, lib, pkgs, ... }: { ... }` contract. Can declare `options`, set `config` values, and list `imports`. |
| **NixOS module system** | The framework that merges all imported modules into a single configuration before building the system. Ordering of imports does not matter — it is declarative. |
| **nixos-hardware** | A community library (`github:NixOS/nixos-hardware`) of NixOS modules for specific hardware: ThinkPads, Raspberry Pis, etc. |
| **nixos-unstable** | The rolling-release branch of nixpkgs. Packages are more up-to-date but less stable than the numbered releases. |
| **nixpkgs** | The ~100,000-package collection maintained by the NixOS community. Also contains all NixOS module definitions. |
| **Nix store** | `/nix/store/` — the immutable, content-addressed directory where every package and derivation output lives. Multiple versions coexist. |
| **Option** | A typed, named configuration knob declared in a module. e.g. `vitorf7.hardware.nvidia.enable`. Has a type, default value, and description. |
| **osConfig** | Inside a home-manager module, `config` refers to the home config. `osConfig` is a special argument that exposes the *system-level* NixOS config — used to check `vitorf7.*` flags from home modules. |
| **Overlay** | A function that patches or extends the nixpkgs package set. Not used directly in this config, but some flake inputs use them internally. |
| **PRIME offload** | NVIDIA's hybrid GPU mode: the Intel iGPU drives the display normally, the discrete NVIDIA GPU handles apps launched with `prime-run`. |
| **specialArgs / extraSpecialArgs** | Mechanisms to inject extra variables (like `inputs` and `self`) into every NixOS or home-manager module, beyond the default `config, lib, pkgs`. |
| **SPICE agent** | A virtualisation guest service that enables clipboard sharing and display auto-resize in QEMU/KVM virtual machines. |
| **stateVersion** | A field (e.g. `"26.05"`) that tells NixOS which data migration paths to use for stateful services. Set once at install, never change — it does *not* mean "run NixOS 26.05". |
| **v4l2loopback** | A kernel module that creates virtual video devices. Used here to enable OBS Studio's Virtual Camera feature (`/dev/video1`). |
| **XDG portals** | A desktop integration layer for sandboxed applications. Handles file dialogs, screen capture, and similar under Wayland. |
| **zram** | Compressed in-RAM swap. Uses CPU to compress pages instead of writing them to a slow swap partition — particularly useful on a laptop with limited RAM. |

---

## 1. The Big Picture

### 1.1 What Problem Does This Solve?

On a traditional Linux system, configuration drifts over time. You install packages, edit files in `/etc`, run `systemctl enable` — and after a year you have no idea what state the machine is actually in. Reinstalling means manually remembering everything.

NixOS flips this model. The *entire operating system* — packages installed, services running, kernel parameters, user configuration — is described in a set of Nix files. Run one command and Nix builds exactly that system and atomically switches to it. Change the files, run the command again, and it updates. Break something? Roll back instantly to the previous generation.

This config extends that principle to your user environment via Home Manager. Your dotfiles, shell config, fonts, and desktop packages are all declared the same way.

### 1.2 The Command and What It Triggers

```bash
sudo nixos-rebuild switch --flake .#thinkpad-t480
```

This single command:
1. Reads `flake.nix` and finds the `nixosConfigurations.thinkpad-t480` output
2. Evaluates the entire module tree (merging hundreds of `.nix` files)
3. Builds only what has changed (content-addressed — if the hash matches, it skips the build)
4. Atomically switches the running system by updating symlinks in `/run/current-system/`
5. Registers the new system as a "generation" — accessible from the GRUB boot menu

To roll back: `sudo nixos-rebuild switch --rollback`, or pick a previous generation from GRUB.

### 1.3 The Assembly Line

Here is how a full system gets assembled, top to bottom:

```
flake.nix
  └── mkHost { system = "x86_64-linux", host = "thinkpad-t480" }
        └── nixpkgs.lib.nixosSystem [...]
              ├── modules/options.nix          ← declares vitorf7.* options (all default false)
              ├── hosts/thinkpad-t480/
              │   └── configuration.nix        ← sets hostname, turns vitorf7.* flags on/off
              ├── modules/system/base-system.nix
              │   ├── boot.nix                 ← always active
              │   ├── locale.nix               ← always active
              │   ├── users.nix                ← always active
              │   ├── audio.nix                ← only if hyprland.enable = true
              │   ├── nvidia-hybrid.nix        ← only if nvidia.enable = true
              │   └── ... (14 more modules)
              └── home-manager for vitorf7
                    └── modules/home/default.nix
                          ├── core.nix         ← always active (CLI tools, dotfile symlinks)
                          ├── dev.nix          ← always active (Go, Rust, Node, k9s...)
                          ├── desktop.nix      ← only if desktop.enable = true
                          └── hyprland.nix     ← only if hyprland.enable = true
```

### 1.4 Two Separate Worlds: System vs. Home

NixOS has a clean split:

- **System config** (`modules/system/`) — runs as root. Controls the kernel, services, `/etc/` files, bootloader, hardware drivers.
- **Home config** (`modules/home/`) — runs as `vitorf7`. Controls `~/`, user packages, dotfile symlinks, shell config.

Both are driven by the same `vitorf7.*` feature flags, but they are evaluated in different contexts. You cannot call a home-manager option from a system module or vice versa directly — they communicate via `osConfig` (explained in §5.7).

---

## 2. Nix the Language — Just Enough

You do not need to become a Nix expert to read this config. Here are the only constructs you will actually encounter.

### 2.1 Attribute Sets — the Universal Data Structure

```nix
{
  foo = "bar";
  count = 42;
  nested = {
    deeper = true;
  };
}
```

Everything in NixOS config is attribute sets. The dotted notation `hardware.nvidia.enable = true` is sugar for nested attribute sets. When you see `config.vitorf7.desktop.enable`, you are reading a value from a deeply nested attribute set.

### 2.2 Functions

Nix functions take exactly one argument and return one value. For multi-argument functions, you chain them:

```nix
# Single argument
x: x + 1

# Destructured argument (most common in modules)
{ config, lib, pkgs, ... }: {
  # ... return value
}

# The `...` means "accept (and ignore) any other attributes"
# This is why you can add specialArgs without breaking modules
```

The `lib/mkHost.nix` file is a **curried** two-step function — it looks like this conceptually:

```nix
# Step 1: called once in flake.nix with shared args
{ inputs, self, root }:
  # Step 2: called once per host
  { system, host, extraModules ? [] }:
    nixpkgs.lib.nixosSystem { ... }
```

### 2.3 `let … in` — Local Variables

```nix
# From modules/home/core.nix
let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in {
  home.packages = [ ... ];
  xdg.configFile."fish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
}
```

`let ... in` binds a name to a value for use in the expression that follows. The value does not leak outside.

### 2.4 `inherit` — Reducing Repetition

```nix
# These two are identical:
{ inputs = inputs; self = self; }
{ inherit inputs self; }
```

`inherit` is used constantly in `flake.nix` and `mkHost.nix` when passing variables through function calls.

### 2.5 `with pkgs; [ ... ]` — Namespace Shortcut

```nix
home.packages = with pkgs; [
  git
  neovim
  ripgrep
  # ... instead of pkgs.git, pkgs.neovim, pkgs.ripgrep
];
```

`with X;` brings all attributes of `X` into scope for the following expression. Used in every `home.packages` block.

### 2.6 String Interpolation

```nix
"${config.home.homeDirectory}/dotfiles"
# evaluates to e.g. "/home/vitorf7/dotfiles"
```

The `${}` syntax interpolates any Nix expression into a string. Paths in dotfile symlinks are built this way.

---

## 3. The Store and Derivations

### 3.1 The Nix Store

Every package on NixOS lives in `/nix/store/`. A typical path looks like:

```
/nix/store/abc123def456...-firefox-130.0/bin/firefox
```

The hash (`abc123def456...`) is derived from the entire build recipe — source code, compiler, all dependencies. If any input changes, the hash changes and Nix builds a new path alongside the old one. Nothing is ever modified in place. Multiple versions of the same package coexist without conflict.

This content-addressing is what makes NixOS rollbacks work: when you switch generations, Nix just updates a symlink from `/run/current-system/` to a different store path. The old generation stays in the store until garbage collected.

### 3.2 What a Derivation Is

A **derivation** is the build recipe itself — a `.drv` file in the store that describes:
- Where to get the source (URL + hash, or local path)
- What tools to use (compiler, cmake, meson…)
- What commands to run
- What the output paths are

When you write `pkgs.firefox`, you are referencing a derivation defined in nixpkgs. When the `pkgs/hyprmod.nix` file in this config calls `python3Packages.buildPythonApplication { ... }`, it creates a new derivation for a custom package.

### 3.3 nixpkgs — the Package Repository

```nix
# flake.nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
```

nixpkgs is a GitHub repository containing ~100,000 package definitions and all NixOS module definitions. This config uses the `nixos-unstable` branch, which has the most up-to-date packages at the cost of occasional breakage. The exact git commit is pinned in `flake.lock`.

### 3.4 `config.allowUnfree = true`

nixpkgs restricts packages with non-free licences by default. This config enables them:

```nix
# modules/system/base-system.nix
nixpkgs.config.allowUnfree = true;
```

This is required for: NVIDIA proprietary drivers, Spotify, Mouseless (AppImage), and 1Password.

---

## 4. Flakes — the Project Container

### 4.1 Why Flakes Exist

Before flakes, a NixOS configuration could reference any URL at build time without pinning. Two machines running the same `configuration.nix` a week apart might get different packages. Flakes solve this: all external sources are declared upfront in `inputs`, and `flake.lock` pins every one to a specific git commit.

### 4.2 The `inputs` Block

```nix
# flake.nix (simplified)
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  flake-parts.url = "github:hercules-ci/flake-parts";
  home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";  # <-- important
  };
  zen-browser = {
    url = "github:youwen5/zen-browser-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  brain-shell = {
    url = "github:Brainitech/Brain_Shell/dev";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  ambxst.url = "github:Axenide/Ambxst";
  nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  nix-flatpak.url = "github:gmodena/nix-flatpak";
  # nix-darwin.url = "github:LnL7/nix-darwin";  ← commented out, pending macOS support
};
```

The `inputs.nixpkgs.follows = "nixpkgs"` lines on `home-manager`, `zen-browser`, and `brain-shell` are important: they tell Nix "when this input needs nixpkgs, use *our* nixpkgs instead of downloading its own copy." Without this, you could end up with three slightly different versions of nixpkgs in the store. `nix-flatpak` notably does *not* follow nixpkgs — it pins its own.

### 4.3 `flake.lock`

The lock file records, for every input, the exact git revision and content hash:

```json
"nixpkgs": {
  "locked": {
    "lastModified": 1750000000,
    "narHash": "sha256-...",
    "rev": "abc123...",
    "type": "github"
  }
}
```

Run `nix flake update` to bump all inputs to their latest commits. Run `nix flake lock --update-input zen-browser` to update only one. After either, run `nixos-rebuild switch` to apply.

### 4.4 The `outputs` Function and flake-parts

Without flake-parts, a flake's `outputs` is a single function that returns a big attribute set. With flake-parts, you call `flake-parts.lib.mkFlake` and split the outputs across structured modules:

```nix
# flake.nix
outputs = inputs@{ self, flake-parts, ... }:
  flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

    perSystem = { pkgs, ... }: {
      # Runs once per system in the `systems` list above
      packages.hyprmod = pkgs.callPackage ./pkgs/hyprmod.nix {};
    };

    flake = {
      # Architecture-agnostic outputs
      nixosConfigurations = {
        thinkpad-t480 = mkHost { system = "x86_64-linux"; host = "thinkpad-t480"; extraModules = [...]; };
        nixos-arm-vm  = mkHost { system = "aarch64-linux"; host = "nixos-arm-vm"; };
        nixos-x86-vm  = mkHost { system = "x86_64-linux"; host = "nixos-x86-vm"; };
      };
    };
  };
```

The `perSystem` block builds the `hyprmod` custom package for every architecture in `systems`. This is how `self.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod` works in `modules/home/hyprland.nix` — `self` refers to this flake itself.

---

## 5. The Module System

This is the single most important concept for understanding NixOS. Everything else builds on it.

### 5.1 What a Module Is

A module is a `.nix` file that follows this contract:

```nix
{ config, lib, pkgs, ... }: {
  # optional: declare new options
  options = { ... };

  # optional: set config values
  config = { ... };

  # optional: import other modules
  imports = [ ... ];
}
```

When there is no `options` key, the top-level attribute set *is* the config (a common shorthand). The `...` in the function argument accepts any extra variables injected via `specialArgs`.

### 5.2 `imports` — Composing Modules

`imports` is a list of other module files to pull in. The NixOS module system **merges** all imported modules before evaluating. Order does not matter.

`modules/system/base-system.nix` is the clearest example — it does nothing except import all other system modules:

```nix
# modules/system/base-system.nix
{ ... }: {
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./display.nix
    ./fingerprint.nix
    # ... all 14 system modules
  ];

  # Three unconditional settings:
  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.gpu-screen-recorder.enable = true;
}
```

Every host imports `base-system.nix`, which pulls in all 14 system modules at once. But most of those modules only *activate* conditionally.

### 5.3 `options` — Declaring Configuration Knobs

The `options` key declares what *can* be configured. It does not set values — it just registers the knob.

```nix
# modules/options.nix (simplified)
{ lib, ... }: {
  options.vitorf7 = {
    desktop = {
      enable = lib.mkEnableOption "Desktop environment";
      hyprland.enable = lib.mkEnableOption "Hyprland window manager";
      quickshell.enable = lib.mkEnableOption "Quickshell framework";
      qs_brain_shell.enable = lib.mkEnableOption "Brain_Shell config";
      ambxst.enable = lib.mkEnableOption "Ambxst shell";
      flatpak.enable = lib.mkEnableOption "Declarative Flatpak";
    };
    hardware = {
      nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
      fingerprint.enable = lib.mkEnableOption "Fingerprint reader";
      vm.enable = lib.mkEnableOption "QEMU VM guest";
    };
  };
}
```

`lib.mkEnableOption "description"` creates `{ type = lib.types.bool; default = false; description = "..."; }`. All 9 options default to `false`. A fresh host starts with nothing enabled.

### 5.4 `config` — Setting Values

The `config` key is where you actually assign values. Most modules in this setup use the shorthand (no explicit `config =` wrapper when there's no `options` key):

```nix
# modules/system/boot.nix
{ ... }: {
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    useOSProber = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };
  boot.loader.efi.canTouchEfiVariables = false;
}
```

This module is always active — no condition. The bootloader is always GRUB EFI.

### 5.5 `lib.mkIf` — Conditional Configuration

This is how feature flags actually work:

```nix
# modules/system/audio.nix
{ config, lib, ... }: lib.mkIf config.vitorf7.desktop.hyprland.enable {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.enable = true;
}
```

The `audio.nix` module is always *imported* (via `base-system.nix`), but its config only *evaluates* when `config.vitorf7.desktop.hyprland.enable` is `true`. On the VMs, Hyprland is disabled, so PipeWire is never configured.

`config.vitorf7.desktop.hyprland.enable` reads the option declared in `options.nix` and set in the host's `configuration.nix`. The module system merges declarations and settings from all imported files — it does not matter which file sets it first.

### 5.6 `specialArgs` and `extraSpecialArgs` — Passing the Flake Context

NixOS modules normally only receive `config`, `lib`, `pkgs`, and `modulesPath`. This config needs to pass `inputs` (to reference flake packages) and `self` (to reference packages built by this very flake):

```nix
# lib/mkHost.nix
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit self; };           # → available in all system modules
  modules = [
    {
      home-manager.extraSpecialArgs = { inherit inputs self; };  # → available in home modules
    }
    # ...
  ];
}
```

This is how `modules/home/desktop.nix` references the Zen browser package from its flake input:

```nix
inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
```

And how `modules/home/hyprland.nix` references the locally-built hyprmod package:

```nix
self.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod
```

### 5.7 `osConfig` — Reaching System Config from Home Manager

Inside a home-manager module, `config` means the *home* config. To read system-level NixOS options from a home module, there is a special argument called `osConfig`:

```nix
# modules/home/desktop.nix
{ config, lib, pkgs, osConfig, inputs, ... }:
lib.mkIf osConfig.vitorf7.desktop.enable {
  # ...
}
```

`osConfig.vitorf7.desktop.enable` reads the same flag that was set in the host's `configuration.nix`. This is how the home and system configs stay in sync without duplication.

### 5.8 Module Merging and `lib.mkOverride`

When two modules both set the same option, NixOS merges them by priority. Lower number = higher precedence:

| Nix helper | Priority number |
|------------|----------------|
| `lib.mkForce value` | 50 (highest) |
| plain `option = value` | 100 (default) |
| `lib.mkDefault value` | 1000 (lowest) |
| `lib.mkOverride 999 value` | 999 (slightly above mkDefault) |

The Ambxst upstream flake sets `programs.ambxst.enable = lib.mkDefault true` (priority 1000). Left alone, Ambxst would always be on. To make it opt-in, `mkHost.nix` counters it:

```nix
# lib/mkHost.nix
({ lib, ... }: {
  programs.ambxst.enable = lib.mkOverride 999 false;
})
```

Priority 999 beats priority 1000, so Ambxst stays off unless `modules/system/ambxst.nix` explicitly sets `programs.ambxst.enable = true` at the default priority (100) — which only happens when `vitorf7.desktop.ambxst.enable = true`.

---

## 6. Layer-by-Layer Walkthrough

### 6.1 Entry Point: `flake.nix`

The three host definitions in `flake.nix`:

```nix
thinkpad-t480 = mkHost {
  system = "x86_64-linux";
  host = "thinkpad-t480";
  extraModules = [
    nixos-hardware.nixosModules.lenovo-thinkpad-t480
    nixos-hardware.nixosModules.common-gpu-nvidia
    nixos-hardware.nixosModules.common-gpu-nvidia-nonflake
  ];
};
nixos-arm-vm = mkHost { system = "aarch64-linux"; host = "nixos-arm-vm"; };
nixos-x86-vm = mkHost { system = "x86_64-linux";  host = "nixos-x86-vm"; };
```

The ThinkPad gets `extraModules` with three nixos-hardware entries. The VMs get none — they are generic virtual machines with no unusual hardware.

### 6.2 `lib/mkHost.nix` — The Host Builder

Every host uses `mkHost` instead of calling `nixpkgs.lib.nixosSystem` directly. This eliminates per-host boilerplate. The assembled module list for every host is:

1. `{ nixpkgs.hostPlatform = system; }` — sets the CPU architecture
2. `hosts/<hostname>/configuration.nix` — host-specific options and flags
3. `modules/options.nix` — registers the `vitorf7.*` option namespace
4. `inputs.brain-shell.nixosModules.default` — upstream Brain_Shell NixOS module
5. `inputs.ambxst.nixosModules.default` — upstream Ambxst NixOS module
6. The `lib.mkOverride 999 false` block — makes Ambxst opt-in
7. `inputs.home-manager.nixosModules.home-manager` — wires Home Manager into the OS build
8. The home-manager user block (sets `useGlobalPkgs`, `useUserPackages`, `users.vitorf7`)
9. `extraModules` — host-specific hardware modules (empty for VMs)

The home-manager block is worth understanding:

```nix
{
  home-manager.useGlobalPkgs = true;       # share the system's pkgs — no separate nixpkgs instance
  home-manager.useUserPackages = true;     # install home packages into /etc/profiles/per-user/
  home-manager.extraSpecialArgs = { inherit inputs self; };
  home-manager.users.vitorf7 = import (root + "/modules/home/default.nix");
}
```

`useGlobalPkgs = true` is important: it means home modules share the same nixpkgs as the system, so `inputs.nixpkgs.follows` on home-manager (set in `flake.nix`) actually takes effect.

### 6.3 `hosts/thinkpad-t480/configuration.nix` — Setting the Flags

The host config is deliberately minimal. Its job is to declare hostname and flip the relevant options:

```nix
{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    ../../modules/system/nvidia-hybrid.nix
    ../../modules/system/fingerprint.nix
  ];

  networking.hostName = "thinkpad-t480";
  system.stateVersion = "26.05";

  # Feature flags
  vitorf7.desktop.enable = true;
  vitorf7.desktop.hyprland.enable = true;
  vitorf7.desktop.quickshell.enable = true;
  vitorf7.desktop.ambxst.enable = true;
  vitorf7.desktop.flatpak.enable = true;
  vitorf7.hardware.nvidia.enable = true;
  vitorf7.hardware.fingerprint.enable = true;

  # NVIDIA-specific kernel parameters
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];

  # Hyprland needs the NVIDIA DRM device; PRIME offload shifts card numbering
  environment.sessionVariables."AQ_DRM_DEVICES" = "/dev/dri/card1";
}
```

Compare this to `hosts/nixos-arm-vm/configuration.nix`, which enables `desktop`, `hyprland`, `quickshell`, `qs_brain_shell`, and `vm`, but not `nvidia`, `fingerprint`, or `flatpak`. The exact same module tree, different flags, different system.

> **Note on `stateVersion`:** `"26.05"` does not mean you are running NixOS 26.05. It is a migration version set once at install. NixOS uses it to know whether to automatically upgrade the data formats of stateful services (databases, etc.). Never change it.

### 6.4 `hosts/thinkpad-t480/hardware-configuration.nix`

This file is auto-generated by `nixos-generate-config`. It is the one file in this config that is *not* portable — it contains hardware identifiers unique to this machine:

```nix
boot.initrd.luks.devices."luks-60815b98-..." = {
  device = "/dev/disk/by-uuid/60815b98-...";
  keyFile = "/crypto_keyfile.bin";
};

fileSystems."/" = {
  device = "/dev/mapper/luks-60815b98-...";
  fsType = "btrfs";
  options = [ "subvol=@" ];
};
fileSystems."/home" = {
  device = "/dev/mapper/luks-60815b98-...";
  fsType = "btrfs";
  options = [ "subvol=@home" ];
};
fileSystems."/nix" = {
  device = "/dev/mapper/luks-60815b98-...";
  fsType = "btrfs";
  options = [ "subvol=@nix" ];
};
```

The disk is fully encrypted with LUKS. Inside the encrypted container is a Btrfs filesystem with three subvolumes:
- `@` → `/` (root)
- `@home` → `/home`
- `@nix` → `/nix` (the Nix store — kept separate because it can grow very large)

No swap partition — `power.nix` provides zram-based swap instead.

### 6.5 System Modules — a Tour

All 14+ system modules are always imported. They are conditionally active.

| Module | Condition | What it does |
|--------|-----------|-------------|
| `boot.nix` | always | GRUB EFI, os-prober for dual-boot detection |
| `locale.nix` | always | `Europe/London`, `en_GB.UTF-8` |
| `networking.nix` | always | NetworkManager (no hand-written network files) |
| `users.nix` | always | User `vitorf7`, fish shell, `wheel` + `video` + `audio` groups |
| `webcam.nix` | always | `v4l2loopback` kernel module → `/dev/video1` "OBS Cam" |
| `power.nix` | always | zram swap (50% RAM, zstd, swappiness=100); lid-suspend when `desktop.enable` |
| `audio.nix` | hyprland | PipeWire + WirePlumber, ALSA + PulseAudio compat + 32-bit |
| `bluetooth.nix` | hyprland | Bluetooth daemon + blueman tray applet |
| `display.nix` | desktop | GDM + GNOME session (needed even when Hyprland is the WM) |
| `hyprland.nix` | hyprland | Hyprland WM + XWayland + XDG portals (hyprland + gtk) |
| `security.nix` | desktop | 1Password CLI + GUI + polkit, Zen browser integration |
| `quickshell.nix` | quickshell | upower D-Bus service (battery events for shell widgets) |
| `qs_brain_shell.nix` | qs_brain_shell | Sets `programs.brain-shell.enable = true` (upstream module handles everything) |
| `ambxst.nix` | ambxst | Sets `programs.ambxst.enable = true` (upstream module handles everything) |
| `flatpak.nix` | flatpak | nix-flatpak declarative Flatpak, installs `net.sonuscape.mouseless` |
| `fingerprint.nix` | fingerprint | fprintd daemon + PAM hooks for login, sudo, hyprlock |
| `nvidia-hybrid.nix` | nvidia | PRIME offload, legacy_535 driver, bus IDs, hardware.graphics |
| `vm.nix` | vm | QEMU guest agent + SPICE vdagentd |

### 6.6 Home Manager Modules

Home modules mirror the system module pattern. `modules/home/default.nix` imports all of them:

```nix
# modules/home/default.nix
{ config, ... }: {
  home.username = "vitorf7";
  home.homeDirectory = "/home/vitorf7";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  imports = [
    ./core.nix ./dev.nix ./desktop.nix ./hyprland.nix
    ./theming.nix ./quickshell.nix ./qs_brain_shell.nix ./ambxst.nix
  ];
}
```

**`core.nix`** — Always active. Installs ~28 packages: terminal emulators (ghostty, kitty), tmux, Neovim (via bob-nvim), fish, starship, zoxide, fzf, fd, ripgrep, bat, eza, git, gh, delta, direnv, mise, killall, unzip, and more. Extends `$PATH` for `bob`-managed Neovim and Mason LSP binaries. Creates config symlinks for fish, tmux, neovim, ghostty, kitty, and others.

**`dev.nix`** — Always active. k9s, lazygit, Node.js, Go, rustup (manages the Rust toolchain), opencode. Symlinks the k9s config.

**`desktop.nix`** — Active when `vitorf7.desktop.enable`. SSH configured to use 1Password as the authentication agent (socket `~/.1password/agent.sock`). Installs Zen browser (from `inputs.zen-browser`), Monaspace Nerd Font, v4l-utils, easyeffects, alsa-utils, Spotify (x86_64 only). Sets Zen as default browser. Sets Wayland environment variables (`MOZ_ENABLE_WAYLAND`, `NIXOS_OZONE_WL`, `QT_QPA_PLATFORM=wayland`, etc.).

**`hyprland.nix`** — Active when `vitorf7.desktop.hyprland.enable`. Installs the full Hyprland ecosystem: hyprlock, hypridle, hyprsunset, hyprshot, wlogout, rofi-wayland, waybar, swaync, networkmanagerapplet, swayosd, nwg-look, nwg-dock-hyprland, lxqt-policykit, and the custom `hyprmod` package (`self.packages.${system}.hyprmod`). Symlinks configs for hypr, rofi, waybar, swaync, wlogout, and matugen.

**`theming.nix`** — Active when `vitorf7.desktop.enable`. Rose Pine GTK theme, Rose Pine hyprcursor, Papirus Dark icons. Uses `dconf.settings` for GNOME-compatible interface preferences (dark mode, cursor, theme) and `qt.platformTheme.name = "gtk3"` for Qt apps.

### 6.7 The `mkOutOfStoreSymlink` Pattern — Editable Dotfiles

This is the key to how dotfiles work in this setup:

```nix
# modules/home/core.nix
let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in {
  xdg.configFile."fish" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
  };
}
```

A regular `file.source = ./somefile` would **copy** the file into `/nix/store/` and make it immutable. `mkOutOfStoreSymlink` instead creates a symlink that points *outside* the store — to a path in your live dotfiles repository.

Result: `~/.config/fish` → `~/dotfiles/fish/.config/fish`

You can edit files in `~/dotfiles/fish/` directly and changes take effect immediately without running `nixos-rebuild`. The dotfiles repo uses `stow`-style directory layout, and Home Manager creates the symlinks pointing into it.

---

## 7. Custom Patterns

### 7.1 The `vitorf7.*` Feature Flag System

The entire system's modularity rests on nine boolean options in `modules/options.nix`. The flow for any feature:

```
options.nix          → declares the option (default false)
    ↓
hosts/*/conf...nix   → sets option true for the relevant host
    ↓
modules/system/X.nix → lib.mkIf config.vitorf7.X.enable { ... }  (system effect)
modules/home/X.nix   → lib.mkIf osConfig.vitorf7.X.enable { ... } (home effect)
```

The `assertions` pattern in some home modules catches dependency errors at eval time, before anything is built:

```nix
# modules/home/qs_brain_shell.nix
{ osConfig, lib, ... }: lib.mkIf osConfig.vitorf7.desktop.qs_brain_shell.enable {
  assertions = [{
    assertion = osConfig.vitorf7.desktop.quickshell.enable;
    message = "vitorf7.desktop.qs_brain_shell.enable requires vitorf7.desktop.quickshell.enable = true";
  }];
}
```

If you enable `qs_brain_shell` without enabling `quickshell`, the build fails with a clear, human-readable message instead of a cryptic error.

### 7.2 nixos-hardware — Hardware Quirk Library

Rather than copy-pasting hardware-specific tweaks from the NixOS wiki, this config uses nixos-hardware modules for the ThinkPad T480. Three modules are applied via `extraModules` in `flake.nix`:

1. **`lenovo-thinkpad-t480`** — Applies BD-PROCHOT thermal throttling fix (prevents the CPU from being unnecessarily throttled), enables TrackPoint scroll emulation, enables `fstrim` for SSD health.

2. **`common-gpu-nvidia`** — Sets `hardware.nvidia.open = false` (closed-source driver), `services.xserver.videoDrivers = ["nvidia"]`, enables PRIME offload.

3. **`common-gpu-nvidia-nonflake`** (or `common/gpu/nvidia/pascal`) — Sets the NVIDIA driver package to `nvidiaPackages.legacy_580` via `lib.mkDefault`.

The `lib.mkDefault` on the driver is intentional — it allows your `modules/system/nvidia-hybrid.nix` to override it with `legacy_535` using a plain assignment (priority 100 beats mkDefault's 1000). This is the discovered-through-use driver version that actually works on this specific T480.

### 7.3 Custom Derivation: `pkgs/hyprmod.nix`

hyprmod is a GTK4/libadwaita Python application not yet packaged in nixpkgs. The derivation builds it from source. Its five Python dependencies are also absent from nixpkgs, so they are built inline:

```nix
# pkgs/hyprmod.nix (simplified structure)
{ lib, pkgs, python3Packages, ... }:
let
  # Build each missing Python dep inline
  hyprland-socket = python3Packages.buildPythonPackage {
    pname = "hyprland-socket";
    version = "...";
    src = fetchFromGitHub { owner = ".."; repo = ".."; tag = ".."; hash = "sha256-..."; };
  };
  # ... four more inline deps
in
python3Packages.buildPythonApplication {
  pname = "hyprmod";
  version = "0.4.0";
  src = fetchFromGitHub { owner = "BlueManCZ"; repo = "hyprmod"; tag = "v0.4.0"; hash = "sha256-..."; };

  nativeBuildInputs = [ pkgs.wrapGAppsHook4 pkgs.gobject-introspection ];
  buildInputs = [ pkgs.gtk4 pkgs.libadwaita ];
  dependencies = [ hyprland-socket ... ];

  # Injects GApps environment and adds Lua 5.4 to PATH
  makeWrapperArgs = [ "--prefix" "PATH" ":" "${pkgs.lua54Packages.lua}/bin" ];
}
```

Key points:
- `fetchFromGitHub` pins both the git tag and the content hash (`sha256-...`). Any tampering changes the hash and Nix refuses to build.
- `wrapGAppsHook4` is a NixOS build hook that automatically sets `GI_TYPELIB_PATH`, `XDG_DATA_DIRS`, and other environment variables needed for GTK4 apps to find their GObject typelib files at runtime.
- The package is exposed in `flake.nix` `perSystem` so it builds for all architectures and is accessible as `self.packages.${system}.hyprmod`.

> **Note:** A nixpkgs PR (#505419) is open to add hyprmod upstream. Once merged, `pkgs/hyprmod.nix` can be deleted and replaced with `pkgs.hyprmod`.

### 7.4 Custom Derivation: `pkgs/mouseless.nix`

Mouseless ships as a pre-built AppImage rather than source code. No compilation needed:

```nix
# pkgs/mouseless.nix (simplified)
{ pkgs, lib, ... }:
let
  sources = {
    "x86_64-linux" = {
      url = "https://github.com/.../mouseless-1.0.0-preview.3-x86_64.AppImage";
      hash = "sha256-...";
    };
    "aarch64-linux" = {
      url = "https://github.com/.../mouseless-1.0.0-preview.3-aarch64.AppImage";
      hash = "sha256-...";
    };
  };
  src = pkgs.fetchurl {
    url = sources.${pkgs.stdenv.hostPlatform.system}.url;
    hash = sources.${pkgs.stdenv.hostPlatform.system}.hash;
  };
in
pkgs.appimageTools.wrapAppImage {
  name = "mouseless";
  src = src;
  meta.license = lib.licenses.unfree;
}
```

`appimageTools.wrapAppImage` handles everything: it unpacks the AppImage, creates an FHS-compatible sandbox, and produces a standard Nix package with a launcher script that works with NixOS's non-standard filesystem layout.

> **Note:** This derivation exists as an alternative approach, but Mouseless is currently installed via Flatpak in `modules/system/flatpak.nix`. Both options exist in the repo.

---

## 8. Full Trace: The NVIDIA Feature Flag

Tracing `vitorf7.hardware.nvidia.enable = true` from declaration to running GPU.

**Step 1 — Declaration** (`modules/options.nix`):
```nix
hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
```
This creates the option. Without it, setting the flag would be a NixOS type error ("undefined option").

**Step 2 — Setting** (`hosts/thinkpad-t480/configuration.nix`):
```nix
vitorf7.hardware.nvidia.enable = true;
```
This is the only place this flag is set to `true`. The VMs leave it at the default `false`.

**Step 3 — Guard check** (`modules/system/nvidia-hybrid.nix`):
```nix
{ config, lib, ... }: lib.mkIf config.vitorf7.hardware.nvidia.enable {
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;  # overrides nixos-hardware's legacy_580
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # disabled: causes crashes with external display
    prime.offload.enable = true;
    prime.intelBusId = "PCI:0:2:0";      # must match `lspci` output on this machine
    prime.nvidiaBusId = "PCI:1:0:0";
  };
  hardware.graphics.enable = true;       # required for PRIME; nixos-hardware doesn't set this
}
```

**Step 4 — nixos-hardware interaction**: The three `extraModules` in `flake.nix` use `lib.mkDefault` for the driver package (priority 1000). The plain assignment in `nvidia-hybrid.nix` (priority 100) wins, selecting `legacy_535` over the upstream `legacy_580`.

**Step 5 — Kernel parameters** (`hosts/thinkpad-t480/configuration.nix`):
```nix
boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
```
Required for Hyprland to use NVIDIA's DRM interface. Added on top of what nixos-hardware sets.

**Step 6 — DRM device pin** (`hosts/thinkpad-t480/configuration.nix`):
```nix
environment.sessionVariables."AQ_DRM_DEVICES" = "/dev/dri/card1";
```
PRIME offload shifts the DRM card numbering (the Intel iGPU becomes card0, NVIDIA becomes card1). Hyprland needs to be told which card to use.

**End result**: On the ThinkPad, the Intel HD Graphics 620 (iGPU) drives all displays at low power. Applications launched with `prime-run <app>` (or `nvidia-offload` wrapper) use the NVIDIA MX150 (dGPU). The discrete GPU is suspended when idle.

---

## 9. Practical Reference

### Adding a Package to Your User Environment

- **Always installed**: add to `home.packages` in `modules/home/core.nix` (CLI/dev tools) or `dev.nix`
- **Only when desktop is on**: add inside `lib.mkIf osConfig.vitorf7.desktop.enable` in `modules/home/desktop.nix`
- **Only when Hyprland is on**: add to `modules/home/hyprland.nix`
- **System-wide** (available to all users): add to `environment.systemPackages` in a system module

### Adding a System Service

For a new unconditional service: create a file in `modules/system/`, add it to the `imports` list in `base-system.nix`.

For a service gated on an existing flag: add it inside a `lib.mkIf` block in the appropriate module.

For a brand-new feature (with its own flag):
1. Add the option to `modules/options.nix`
2. Create `modules/system/myfeature.nix` with `lib.mkIf config.vitorf7.myfeature.enable { ... }`
3. Add `./myfeature.nix` to `modules/system/base-system.nix`'s imports
4. Set `vitorf7.myfeature.enable = true;` in the relevant host's `configuration.nix`

### Adding a New Host

1. Create `hosts/<name>/configuration.nix` — set hostname and `vitorf7.*` flags
2. Run `sudo nixos-generate-config` on the target machine, place the output at `hosts/<name>/hardware-configuration.nix`
3. Add to `flake.nix`: `<name> = mkHost { system = "<arch>-linux"; host = "<name>"; };`
4. If the machine has special hardware: add nixos-hardware modules via `extraModules`

### Updating Packages

```bash
# Update all inputs to their latest commits
nix flake update

# Update only one input
nix flake lock --update-input zen-browser

# Apply the update
sudo nixos-rebuild switch --flake .#<hostname>
```

### Dry Run and Rollback

```bash
# See what would change without applying
sudo nixos-rebuild dry-activate --flake .#<hostname>

# Build but don't switch
sudo nixos-rebuild build --flake .#<hostname>

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback
```

---

## 10. What Isn't Here Yet

### nix-darwin / macOS M1

The flake is already prepared: `aarch64-darwin` is in the `systems` list, so `perSystem` builds work for it (e.g. `hyprmod` is attempted for that arch). The `nix-darwin` input is commented out in `flake.nix`. Adding `darwinConfigurations.darwin-m1` would follow the same mkHost-like pattern, but nix-darwin uses its own module system (not NixOS modules) — some modules would need darwin-specific variants.

### mouseless.nix — the Nix Path Not Taken

The `pkgs/mouseless.nix` derivation is complete and correct, but Mouseless is currently installed via Flatpak in `modules/system/flatpak.nix`. If you wanted to switch to the Nix-native approach:
1. Remove the Flatpak entry from `modules/system/flatpak.nix`
2. Add `pkgs.callPackage ../../pkgs/mouseless.nix {}` to `home.packages` in a home module

### nixos-arm-vm `hardware-configuration.nix`

The ARM VM's `configuration.nix` imports `./hardware-configuration.nix`, but that file does not exist in the repo. It must be generated on the actual VM machine before first deploy:

```bash
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
```

This is by design — hardware configs are machine-specific and not portable.

### hyprmod — Temporary Derivation

`pkgs/hyprmod.nix` exists because hyprmod is not yet in nixpkgs. Once nixpkgs PR #505419 is merged, the derivation and all five inline Python dependencies can be replaced with `pkgs.hyprmod`, and the `perSystem.packages.hyprmod` block in `flake.nix` can be removed.
