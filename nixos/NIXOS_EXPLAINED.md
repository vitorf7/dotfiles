# Understanding My NixOS Configuration — A Guided Tour

> This document explains the NixOS/nix-darwin setup in `nixos/.nixos/` from first principles.
> It assumes you know Linux (and a bit of macOS) but have little to no prior Nix experience.
> All file paths are relative to `nixos/.nixos/` unless stated otherwise.
>
> This config follows the ["dendritic" flake-parts pattern](https://github.com/mightyiam/dendritic),
> implemented with [`import-tree`](https://github.com/vic/import-tree). If you've read Nix docs
> that talk about `imports = [ ./foo.nix ./bar.nix ]` lists, this repo intentionally has almost
> none of those — that's the whole point of the pattern, and it's explained in §4–§5 below.

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
| **Dendritic pattern** | A flake-parts convention (see [mightyiam/dendritic](https://github.com/mightyiam/dendritic)) where every module file auto-registers itself into a shared `flake.modules.<class>.<name>` registry and there is no hand-written list of imports anywhere in the flake. This repo implements it with `import-tree`. |
| **Derivation** | A build recipe stored in `/nix/store/`. Describes what source code, build tools, and commands produce a specific package. The output path is determined entirely by the inputs, so it is perfectly reproducible. |
| **Flake** | A standardised Nix project format. Has a `flake.nix` with `inputs` (pinned external sources) and `outputs` (packages, NixOS configs, etc.). Version-locked by `flake.lock`. |
| **flake-parts** | A library (`github:hercules-ci/flake-parts`) that splits a flake's `outputs` into composable modules, one of which can vary per system architecture. |
| **flake.lock** | Auto-generated file that records the exact git commit hash and content hash of every flake input. Makes builds reproducible. Never edit by hand. |
| **`flake.modules` registry** | An attrset, `{ nixos.<name> = ...; darwin.<name> = ...; homeManager.<name> = ...; }`, that every module file writes into. Declared in `modules/flake-modules-type.nix` (see §5.3). Host files read named entries back out via `self.modules.<class>.<name>`. |
| **GDM** | GNOME Display Manager — the graphical login screen. This config uses it even with Hyprland as the window manager. |
| **Home Manager** | A NixOS/nix-darwin module (and standalone tool) that manages your *user-level* environment — dotfiles, user packages, shell configuration — declaratively. |
| **`import-tree`** | The flake input (`github:vic/import-tree`) that recursively finds every `.nix` file under a directory and imports each one as a flake-parts module. This is the mechanism that makes the dendritic pattern possible here — see §4.4. |
| **lib.mkDefault** | Sets a config value at low priority (1000). Can be overridden by a plain assignment (priority 100) or `lib.mkForce`. |
| **lib.mkEnableOption** | A nixpkgs helper that creates a boolean `enable` option defaulting to `false`. Used in `modules/options.nix` for almost all feature flags. |
| **lib.mkForce** | Sets a config value at the highest priority, overriding everything else. |
| **lib.mkIf** | Conditionally applies a config block. `lib.mkIf condition { ... }` — the block only evaluates when `condition` is true. |
| **lib.mkOverride N** | Sets a value at explicit priority `N`. Lower N = higher precedence. Plain assignment = 100, `mkDefault` = 1000, `mkForce` = 50. |
| **Module** | A `.nix` file that follows the `{ config, lib, pkgs, ... }: { ... }` contract. In this repo, most modules' top-level job is to assign into `flake.modules.<class>.<name>` rather than declare `options`/`config` directly (that happens one level down, inside the assigned value). |
| **NixOS module system** | The framework that merges all imported modules into a single configuration before building the system. Ordering of imports does not matter — it is declarative. |
| **nixos-hardware** | A community library (`github:NixOS/nixos-hardware`) of NixOS modules for specific hardware: ThinkPads, Raspberry Pis, etc. |
| **nixos-unstable** | The rolling-release branch of nixpkgs. Packages are more up-to-date but less stable than the numbered releases. |
| **nixpkgs** | The ~100,000-package collection maintained by the NixOS community. Also contains all NixOS module definitions. |
| **Nix store** | `/nix/store/` — the immutable, content-addressed directory where every package and derivation output lives. Multiple versions coexist. |
| **Option** | A typed, named configuration knob declared in a module. e.g. `vitorf7.hardware.nvidia.enable`. Has a type, default value, and description. |
| **osConfig** | Inside a home-manager module, `config` refers to the home config. `osConfig` is a special argument that exposes the *system-level* NixOS/darwin config — used to check `vitorf7.*` flags from home modules. |
| **Overlay** | A function that patches or extends the nixpkgs package set. Used sparingly here (see `nix-base.nix`'s `throttled` overlay fixing a missing Python dependency). |
| **PRIME offload** | NVIDIA's hybrid GPU mode: the Intel iGPU drives the display normally, the discrete NVIDIA GPU handles apps launched with `prime-run`. |
| **`self`** | Inside a flake-parts module, `self` is the flake's own (fixed-point) output set. Host files use `self.modules.nixos.*` / `self.modules.darwin.*` / `self.modules.homeManager.*` to pull named modules back out of the registry other files wrote into. |
| **sops-nix** | A NixOS/home-manager module (`github:Mic92/sops-nix`) that decrypts age- or PGP-encrypted secrets at activation time and exposes them as files/templates. Used here alongside strongbox — see §7.5. |
| **specialArgs / extraSpecialArgs** | Mechanisms to inject extra variables (like `inputs` and `self`) into every NixOS or home-manager module, beyond the default `config, lib, pkgs`. |
| **SPICE agent** | A virtualisation guest service that enables clipboard sharing and display auto-resize in QEMU/KVM virtual machines. |
| **stateVersion** | A field (e.g. `"26.05"`) that tells NixOS/home-manager which data migration paths to use for stateful services. Set once at install, never change — it does *not* mean "run NixOS 26.05". |
| **v4l2loopback** | A kernel module that creates virtual video devices. Used here to enable OBS Studio's Virtual Camera feature (`/dev/video1`). |
| **XDG portals** | A desktop integration layer for sandboxed applications. Handles file dialogs, screen capture, and similar under Wayland. |
| **zram** | Compressed in-RAM swap. Uses CPU to compress pages instead of writing them to a slow swap partition — particularly useful on a laptop with limited RAM. |

---

## 1. The Big Picture

### 1.1 What Problem Does This Solve?

On a traditional Linux or macOS system, configuration drifts over time. You install packages, edit files by hand, run one-off setup commands — and after a year you have no idea what state the machine is actually in. Reinstalling means manually remembering everything.

NixOS (and, via nix-darwin, macOS) flips this model. The *entire operating system* — packages installed, services running, kernel parameters, user configuration — is described in a set of Nix files. Run one command and Nix builds exactly that system and atomically switches to it. Change the files, run the command again, and it updates. Break something? Roll back instantly to the previous generation.

This config extends that principle to your user environment via Home Manager, and to macOS via nix-darwin. Your dotfiles, shell config, fonts, and desktop packages are all declared the same way, on both platforms.

### 1.2 The Command and What It Triggers

```bash
sudo nixos-rebuild switch --flake .#thinkpad-t480
# or on macOS:
sudo darwin-rebuild switch --flake .#uw-mac-m1
```

This single command:
1. Reads `flake.nix`, which hands `import-tree ./modules` to `flake-parts.lib.mkFlake` — every `.nix` file under `modules/` gets imported and evaluated as part of one big flake-parts module tree
2. Finds the `nixosConfigurations.thinkpad-t480` (or `darwinConfigurations.uw-mac-m1`) output that the matching host file under `modules/hosts/` defined
3. Builds only what has changed (content-addressed — if the hash matches, it skips the build)
4. Atomically switches the running system by updating symlinks in `/run/current-system/`
5. Registers the new system as a "generation" — accessible from the GRUB boot menu (NixOS) or via `darwin-rebuild --rollback` (macOS)

To roll back: `sudo nixos-rebuild switch --rollback`, or pick a previous generation from GRUB.

### 1.3 The Assembly Line

Here is how a full system gets assembled, top to bottom:

```
flake.nix
  └── import-tree ./modules            ← recursively imports every .nix file under modules/
        ├── modules/flake-modules-type.nix   ← declares the flake.modules registry option itself
        ├── modules/options.nix              ← flake.modules.{nixos,darwin}.options — vitorf7.* tree
        ├── modules/nix-base.nix             ← flake.modules.nixos.nix-base (always-on)
        ├── modules/nvidia.nix               ← flake.modules.nixos.nvidia (lib.mkIf vitorf7.hardware.nvidia.enable)
        ├── modules/git.nix                  ← flake.modules.{darwin,homeManager}.git
        ├── ... (~50 more single-purpose module files, each registering into flake.modules.*)
        ├── modules/packages.nix             ← perSystem block building custom pkgs (the one non-dendritic file)
        └── modules/hosts/
              └── thinkpad-t480/default.nix  ← reads self.modules.nixos.* / self.modules.homeManager.*
                    by name, assembles nixosSystem { modules = [ ... ]; },
                    sets flake.nixosConfigurations.thinkpad-t480
```

Nothing in `flake.nix` lists "the modules for thinkpad-t480" — that list lives entirely inside
`modules/hosts/thinkpad-t480/default.nix`, which is itself just another file `import-tree`
happened to discover.

### 1.4 Two Separate Worlds: System vs. Home

NixOS/nix-darwin has a clean split:

- **System config** (`flake.modules.nixos.*` / `flake.modules.darwin.*`) — runs as root. Controls the kernel, services, `/etc/` files, bootloader, hardware drivers (or, on macOS, `system.defaults`, Homebrew, launchd).
- **Home config** (`flake.modules.homeManager.*`) — runs as the primary user. Controls `~/`, user packages, dotfile symlinks, shell config.

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

Everything in NixOS config is attribute sets. The dotted notation `hardware.nvidia.enable = true` is sugar for nested attribute sets. When you see `config.vitorf7.desktop.enable`, you are reading a value from a deeply nested attribute set. The `flake.modules.nixos.nvidia = ...` assignments you'll see throughout `modules/` are exactly this same sugar, just one level higher — writing into `flake.modules.nixos.<name>`.

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

Most files in `modules/` are themselves a top-level function `{ ... }: { flake.modules.<class>.<name> = <another function>; }` — a module that produces a module. `modules/git.nix` is a good example of this two-layer shape (see §5.2).

### 2.3 `let … in` — Local Variables

```nix
# From modules/shell.nix
let
  dot = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  xdg.configFile."tmux".source = link "${dot}/tmux/.config/tmux";
}
```

`let ... in` binds a name to a value for use in the expression that follows. The value does not leak outside.

### 2.4 `inherit` — Reducing Repetition

```nix
# These two are identical:
{ inputs = inputs; self = self; }
{ inherit inputs self; }
```

`inherit` shows up constantly in `flake.nix` and in host files under `modules/hosts/` when passing `inputs`/`self` through.

### 2.5 `with pkgs; [ ... ]` and `with self.modules.homeManager; [ ... ]`

```nix
home.packages = with pkgs; [
  git
  neovim
  ripgrep
];
```

`with X;` brings all attributes of `X` into scope for the following expression. Used in every `home.packages` block, and — a pattern specific to this repo — in every host's home-manager import list:

```nix
# modules/hosts/thinkpad-t480/default.nix
home-manager.users.${username} = { ... }: {
  imports = with self.modules.homeManager; [
    core shell editor git secrets dev desktop onepassword
    browsers media communication ai gaming
  ];
};
```

Here `with self.modules.homeManager;` brings every registered home-manager module (`core`, `shell`, `editor`, …) into scope by name, so the host can list exactly the ones it wants.

### 2.6 String Interpolation

```nix
"${config.home.homeDirectory}/dotfiles"
# evaluates to e.g. "/home/vitorf7/dotfiles" or "/Users/vitorfaiante/dotfiles"
```

The `${}` syntax interpolates any Nix expression into a string. Paths in dotfile symlinks are built this way.

---

## 3. The Store and Derivations

### 3.1 The Nix Store

Every package on NixOS/nix-darwin lives in `/nix/store/`. A typical path looks like:

```
/nix/store/abc123def456...-firefox-130.0/bin/firefox
```

The hash (`abc123def456...`) is derived from the entire build recipe — source code, compiler, all dependencies. If any input changes, the hash changes and Nix builds a new path alongside the old one. Nothing is ever modified in place. Multiple versions of the same package coexist without conflict.

This content-addressing is what makes rollbacks work: when you switch generations, Nix just updates a symlink from `/run/current-system/` (or the darwin equivalent) to a different store path. The old generation stays in the store until garbage collected.

### 3.2 What a Derivation Is

A **derivation** is the build recipe itself — a `.drv` file in the store that describes:
- Where to get the source (URL + hash, or local path)
- What tools to use (compiler, cmake, meson…)
- What commands to run
- What the output paths are

When you write `pkgs.firefox`, you are referencing a derivation defined in nixpkgs. The `pkgs/*.nix` files in this config (e.g. `pkgs/go-latest.nix`) create new derivations for custom packages not in nixpkgs.

### 3.3 nixpkgs — the Package Repository

```nix
# flake.nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
```

nixpkgs is a GitHub repository containing ~100,000 package definitions and all NixOS module definitions. This config uses the `nixos-unstable` branch, which has the most up-to-date packages at the cost of occasional breakage. The exact git commit is pinned in `flake.lock`.

### 3.4 `config.allowUnfree = true`

nixpkgs restricts packages with non-free licences by default. This config enables them in `modules/nix-base.nix`:

```nix
flake.modules.nixos.nix-base = { ... }: {
  nixpkgs.config.allowUnfree = true;
  # ...
};
```

This is required for: NVIDIA proprietary drivers, Spotify, and 1Password, among others.

---

## 4. Flakes — the Project Container

### 4.1 Why Flakes Exist

Before flakes, a NixOS configuration could reference any URL at build time without pinning. Two machines running the same config a week apart might get different packages. Flakes solve this: all external sources are declared upfront in `inputs`, and `flake.lock` pins every one to a specific git commit.

### 4.2 The `inputs` Block

```nix
# flake.nix (abridged)
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  flake-parts.url = "github:hercules-ci/flake-parts";
  import-tree.url = "github:vic/import-tree";

  home-manager = {
    url = "github:nix-community/home-manager/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  nix-darwin = {
    url = "github:LnL7/nix-darwin/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # ... zen-browser, brain-shell, ambxst, caelestia-shell, hyprmod,
  #     nixos-hardware, nix-flatpak — all follow nixpkgs

  # Do NOT set inputs.nixpkgs.follows here: the flake's python-validity package
  # requires nixpkgs 24.11 build conventions that differ from nixos-unstable.
  nixos-06cb-009a-fingerprint-sensor.url =
    "github:ahbnr/nixos-06cb-009a-fingerprint-sensor?ref=24.11";

  # Do NOT set inputs.nixpkgs.follows here: the flake has specific Rust
  # toolchain requirements and bundles the proprietary gpgui binary.
  globalprotect-openconnect.url = "github:yuezk/GlobalProtect-openconnect";
};
```

The `inputs.nixpkgs.follows = "nixpkgs"` lines are important: they tell Nix "when this input needs nixpkgs, use *our* nixpkgs instead of downloading its own copy." Without this, you could end up with several slightly different versions of nixpkgs in the store. Two inputs — the fingerprint-sensor driver and the GlobalProtect client — **deliberately don't follow**, with an inline comment explaining why in each case (see §4.2 snippet above). `nix-flatpak` also doesn't follow nixpkgs.

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

Run `nix flake update` to bump all inputs to their latest commits. Run `nix flake lock --update-input hyprmod` to update only one. After either, run `nixos-rebuild switch`/`darwin-rebuild switch` to apply.

### 4.4 The `outputs` Function — Dendritic-Style, via `import-tree`

Without flake-parts, a flake's `outputs` is a single function that returns a big attribute set. With flake-parts, you call `flake-parts.lib.mkFlake` and hand it a set of modules to compose. Most flake-parts tutorials show this as an explicit list:

```nix
# The "textbook" flake-parts way (NOT what this repo does)
flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [ ./modules/foo.nix ./modules/bar.nix ./modules/baz.nix ];
};
```

This repo instead does the entire thing in one line:

```nix
# flake.nix — the real outputs block, verbatim
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
    (import-tree ./modules);
```

`import-tree ./modules` walks the `modules/` directory recursively (including `modules/hosts/**`) and returns `{ imports = [ <every .nix file found>  ]; }` — mechanically equivalent to writing out the "textbook" list above by hand, except it happens automatically. Adding a new file under `modules/` is enough for it to be picked up; there is nothing else to edit. This is the entire mechanism behind the "dendritic pattern" name: modules branch out from a single root (`import-tree ./modules`) rather than being explicitly wired together.

`perSystem` blocks (see `modules/packages.nix`) work exactly as they do in vanilla flake-parts — `import-tree` doesn't care what shape a given file's module takes, it just imports it.

---

## 5. The Module System

This is the single most important concept for understanding NixOS, nix-darwin, and this repo's specific flavour of flake-parts.

### 5.1 What a Module Is

A flake-parts module is a `.nix` file that follows this contract:

```nix
{ config, lib, pkgs, inputs, self, ... }: {
  # optional: declare new options
  options = { ... };

  # optional: set config values
  config = { ... };

  # optional: import other modules
  imports = [ ... ];
}
```

Almost every file in `modules/` uses this contract at the *flake-parts* level just to write one thing: an entry into `flake.modules.<class>.<name>`. The *value* of that entry is a second, nested module — this time a NixOS, nix-darwin, or home-manager module — which is where the "real" `options`/`config` for that feature actually live.

### 5.2 The `flake.modules.<class>.<name>` Registry Pattern

Rather than one file importing another, every module file independently assigns itself a slot in a shared registry. The two canonical shapes:

**Single-class, always-on** (`modules/nix-base.nix`):

```nix
{ ... }:
{
  flake.modules.nixos.nix-base = { ... }: {
    programs.nix-ld.enable = true;
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    programs.gpu-screen-recorder.enable = true;
  };
}
```

**Dual-class, one file feeding two module classes** (`modules/git.nix`, abridged):

```nix
{ ... }:
{
  flake.modules.darwin.git = { ... }: {
    homebrew.taps = [ { name = "chmouel/lazyworktree"; ... } ];
  };

  flake.modules.homeManager.git = { config, pkgs, lib, osConfig, ... }: {
    programs.git = { enable = true; /* ... */ };
    programs.gh.enable = true;
  };
}
```

There is no aggregator file anywhere that lists "all the modules for a nixos host" — that composition happens per-host, explicitly, in `modules/hosts/<name>/default.nix` (see §6.2). What the registry buys you is: define a feature once, in one file, and let any host that wants it reference it by a short name (`self.modules.nixos.nix-base`) instead of a relative path.

### 5.3 `options` — the Shared `vitorf7.*` Tree, and the Registry's Own Bootstrapping

`modules/options.nix` declares one function, `vitorf7Options`, and assigns it to **two** classes at once:

```nix
# modules/options.nix (abridged)
{ lib, ... }:
let
  vitorf7Options = { lib, ... }: {
    options.vitorf7 = {
      username = lib.mkOption { type = lib.types.str; description = "..."; };
      desktop.enable = lib.mkEnableOption "General desktop environment ...";
      hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
      # ... full tree in README.md's options table
    };
  };
in
{
  flake.modules.nixos.options  = vitorf7Options;
  flake.modules.darwin.options = vitorf7Options;
}
```

Because the *exact same function* is reused for both classes, a NixOS host and a darwin host see an identical `vitorf7.*` option surface — a flag like `vitorf7.git.defaultProfile` behaves the same way regardless of platform.

One more file is worth knowing about here: `modules/flake-modules-type.nix`. `flake.modules` isn't a NixOS/flake-parts builtin — flake-parts has no opinion on what you put under `flake.*`. This repo hand-declares the option so the attrset is legal to write into and merge:

```nix
# modules/flake-modules-type.nix
{ lib, ... }:
{
  options.flake = {
    modules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
      default = {};
      description = "Module registry keyed by class (nixos, darwin, homeManager) then by name.";
    };
    darwinConfigurations = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };
  };
}
```

This is repo-local scaffolding the dendritic convention depends on — `import-tree`/flake-parts don't provide it for you.

### 5.4 `config` — Setting Values

Inside the nested module a `flake.modules.*` entry evaluates to, you set values the normal NixOS way. Most modules use the shorthand (no explicit `config =` wrapper when there's no `options` key):

```nix
# modules/boot.nix
{ ... }:
{
  flake.modules.nixos.boot = { ... }: {
    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.device = "nodev";
    boot.loader.grub.useOSProber = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
```

This module is always active — no condition. The bootloader is always GRUB EFI on every NixOS host.

### 5.5 `lib.mkIf` — Conditional Configuration

This is how feature flags actually work:

```nix
# modules/nvidia.nix
{ ... }:
{
  flake.modules.nixos.nvidia = { config, lib, ... }: lib.mkIf config.vitorf7.hardware.nvidia.enable {
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      prime.intelBusId = "PCI:0:2:0";
      prime.nvidiaBusId = "PCI:1:0:0";
    };
    hardware.graphics.enable = true;
  };
}
```

`nvidia.nix`'s registered module is always *imported* (any host that lists `self.modules.nixos.nvidia` gets it), but its config only *evaluates* when `config.vitorf7.hardware.nvidia.enable` is `true`. On the VMs, this flag stays `false`, so the block never activates — and the VMs don't even list `self.modules.nixos.nvidia` in their module list to begin with, since there's no reason to.

### 5.6 `self` — How a Host File Reaches the Registry

There is no curried "host builder" function anymore — each host file is handed `{ inputs, self, ... }` directly by flake-parts and reaches into the registry itself:

```nix
# modules/hosts/thinkpad-t480/default.nix (abridged)
{ inputs, self, ... }:
let username = "vitorf7";
in
{
  flake.nixosConfigurations.thinkpad-t480 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      self.modules.nixos.options
      self.modules.nixos.nix-base
      ./_hardware-configuration.nix
      { vitorf7.username = username; networking.hostName = "thinkpad-t480"; /* ... */ }
      { vitorf7.desktop.enable = true; vitorf7.hardware.nvidia.enable = true; /* ... */ }
      self.modules.nixos.boot
      self.modules.nixos.locale
      self.modules.nixos.nvidia
      # ...
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.users.${username} = { ... }: {
          imports = with self.modules.homeManager; [ core shell editor git dev desktop /* ... */ ];
        };
      }
    ];
  };
}
```

`self` works here because flake-parts evaluates the whole flake as a fixed point: every module (including every file `import-tree` found) contributes to `self`, and every module can also *read* the fully-merged `self` back — including `self.modules`, which by the time any host file's `modules` list is evaluated already contains every other file's registrations. This is what replaces the old `lib/mkHost.nix` curried function: instead of a helper hiding the module list, each host's full module list is spelled out plainly in its own file.

### 5.7 `osConfig` — Reaching System Config from Home Manager

Inside a home-manager module, `config` means the *home* config. To read system-level options from a home module, there is a special argument called `osConfig`:

```nix
# modules/git.nix — the homeManager half
flake.modules.homeManager.git = { config, pkgs, lib, osConfig, ... }:
  let
    gitCfg = osConfig.vitorf7.git;
  in {
    # gitCfg.defaultProfile, gitCfg.personal.enable, gitCfg.work.directories, etc.
  };
```

`osConfig.vitorf7.git` reads the same flag tree set in the host's identity block. `modules/secrets.nix`'s home-manager half does the same thing to conditionally declare the work git-identity sops secret only `lib.mkIf gitCfg.work.enable`. This is how the home and system configs stay in sync without duplication — unchanged in spirit from before the dendritic migration, just now reached from a flatter set of files.

### 5.8 Module Merging and `lib.mkOverride`

When two modules both set the same option, NixOS merges them by priority. Lower number = higher precedence:

| Nix helper | Priority number |
|------------|----------------|
| `lib.mkForce value` | 50 (highest) |
| plain `option = value` | 100 (default) |
| `lib.mkDefault value` | 1000 (lowest) |
| `lib.mkOverride 999 value` | 999 (slightly above mkDefault) |

The Ambxst upstream flake sets `programs.ambxst.enable = lib.mkDefault true` (priority 1000). Left alone, Ambxst would always be on. To make it opt-in, `thinkpad-t480/default.nix` counters it inline, right next to the other upstream `nixosModules.*` entries:

```nix
inputs.ambxst.nixosModules.default
({ lib, ... }: { programs.ambxst.enable = lib.mkOverride 999 false; })
```

Priority 999 beats priority 1000, so Ambxst stays off unless `modules/ambxst.nix`'s registered module explicitly sets `programs.ambxst.enable = true` at the default priority (100) — which only happens when `vitorf7.desktop.ambxst.enable = true`.

---

## 6. Layer-by-Layer Walkthrough

### 6.1 Entry Point: `flake.nix`

The full file is short — inputs (§4.2), and the one-line outputs block from §4.4:

```nix
outputs = inputs@{ flake-parts, import-tree, ... }:
  flake-parts.lib.mkFlake { inherit inputs; }
    (import-tree ./modules);
```

That's the entire host list, module list, and perSystem wiring, from `flake.nix`'s point of view — everything else lives inside `modules/`.

### 6.2 `modules/hosts/<host>/default.nix` — the Host File

Every host is one file. There's no helper function wrapping `nixosSystem`/`darwinSystem` anymore — the file calls it directly and inlines everything:

1. `{ nixpkgs.hostPlatform = system; }` — pins the CPU architecture
2. `self.modules.nixos.options` (or `.darwin.options`) — the shared `vitorf7.*` option tree
3. `./_hardware-configuration.nix` (NixOS hosts only) — machine-specific hardware
4. A host-identity block — `vitorf7.username`, `networking.hostName`, any host-specific kernel params or session variables
5. A feature-flags block — the `vitorf7.*` flags this specific host turns on
6. An ordered list of `self.modules.nixos.*` / `self.modules.darwin.*` picks — `thinkpad-t480/default.nix` groups these with inline comments ("Phase 2", "Phase 3 cross-class", "Upstream NixOS modules", "nixos-hardware") as an informal but useful convention for reading order
7. Upstream `nixosModules.default`/`darwinModules.*` from flake inputs (Brain_Shell, Ambxst, sops-nix, nixos-hardware)
8. The home-manager block: `useGlobalPkgs`, `useUserPackages`, `sharedModules = [ inputs.sops-nix.homeManagerModules.sops ]`, and `home-manager.users.<username>.imports = with self.modules.homeManager; [ ... ];`

`useGlobalPkgs = true` is important: it means home modules share the same nixpkgs as the system, so `inputs.nixpkgs.follows` (set in `flake.nix`) actually takes effect for home-manager too.

### 6.3 Setting the Flags: `thinkpad-t480/default.nix`'s Feature-Flags Block

```nix
{
  vitorf7.desktop.enable = true;
  vitorf7.desktop.hyprland.enable = true;
  vitorf7.desktop.quickshell.enable = true;
  vitorf7.desktop.caelestia_shell.enable = true;
  vitorf7.desktop.flatpak.enable = true;
  vitorf7.desktop.gaming.enable = true;
  vitorf7.desktop.winboat.enable = true;
  vitorf7.networking.nordvpn.enable = true;
  vitorf7.networking.globalprotect.enable = true;
  vitorf7.networking.wiresteward.enable = true;
  vitorf7.hardware.fingerprint.enable = true;
  vitorf7.hardware.nvidia.enable = true;
  vitorf7.git.defaultProfile = "personal";
  vitorf7.git.personal.enable = true;
  vitorf7.git.work.enable = true;
  system.stateVersion = "26.05";
  # NVIDIA DRM params: modesetting and fbdev handoff on PRIME systems.
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
  # PRIME offload shifts DRM card numbering — pin Hyprland to Intel node.
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";
}
```

Compare this to `modules/hosts/nixos-arm-vm/default.nix`, which enables `desktop`, `hyprland`, and `quickshell`, but not `nvidia`, `fingerprint`, `flatpak`, `gaming`, or any of the VPN flags. Same shared option tree, same module registry, completely different resulting system.

> **Note on `stateVersion`:** `"26.05"` does not mean you are running NixOS 26.05. It is a migration version set once at install. NixOS uses it to know whether to automatically upgrade the data formats of stateful services (databases, etc.). Never change it.

### 6.4 `modules/hosts/thinkpad-t480/_hardware-configuration.nix`

This file is auto-generated by `nixos-generate-config`. It is one of the only files in this config that is *not* portable — it contains hardware identifiers unique to this machine (LUKS UUIDs, Btrfs subvolume layout for `/`, `/home`, `/nix`). No swap partition — `modules/power.nix` provides zram-based swap instead.

`modules/hosts/nixos-arm-vm/` and `nixos-x86-vm/` currently have **no** `_hardware-configuration.nix` at all — only `default.nix`. This is by design (hardware configs are machine-specific and can't be committed ahead of time), but it means those two hosts cannot build until someone runs `nixos-generate-config` on the actual VM and drops the output in place.

### 6.5 System Modules — a Tour (Representative, Not Exhaustive)

There is no single aggregator file listing every NixOS module anymore — run `ls modules/` for the full ~56-file catalog. Here's a representative slice:

| Module | Condition | What it does |
|--------|-----------|-------------|
| `nix-base.nix` | always | `nix-ld`, `allowUnfree`, flakes experimental feature, `throttled` overlay fix |
| `boot.nix` | always | GRUB EFI, os-prober for dual-boot detection |
| `locale.nix` | always | Timezone + locale |
| `users.nix` | always | Primary user, shell, groups |
| `power.nix` | `desktop.enable` | zram swap; lid-suspend behaviour |
| `webcam.nix` | always | `v4l2loopback` kernel module → OBS virtual camera |
| `audio.nix` / `bluetooth.nix` | `desktop.hyprland.enable` | PipeWire/WirePlumber; Bluetooth + blueman |
| `display.nix` | `desktop.enable` | GDM + GNOME session (needed even when Hyprland is the WM) |
| `hyprland.nix` | `desktop.hyprland.enable` | Hyprland WM + XWayland + XDG portals |
| `nvidia.nix` | `hardware.nvidia.enable` | PRIME offload, driver package, bus IDs |
| `fingerprint.nix` | `hardware.fingerprint.enable` | fprintd daemon + PAM hooks |
| `vm.nix` | `hardware.vm.enable` | QEMU guest agent + SPICE vdagentd |
| `flatpak.nix` | `desktop.flatpak.enable` | nix-flatpak declarative Flatpak |
| `gaming.nix` | `desktop.gaming.enable` | Steam/Lutris/emulators |
| `winboat.nix` | `desktop.winboat.enable` | WinBoat (Windows apps via Docker+KVM) |
| `nordvpn.nix` | `networking.nordvpn.enable` | NordVPN client + daemon |
| `globalprotect.nix` | `networking.globalprotect.enable` | GlobalProtect VPN client |
| `wiresteward.nix` | `networking.wiresteward.enable` | Wiresteward WireGuard agent, per-cluster `systemd.network` config |
| `qs-brain-shell.nix` / `ambxst.nix` / `caelestia-shell.nix` / `quickshell.nix` | respective flags | Quickshell-based desktop shells |
| `secrets.nix` | always (nixos half) | `sops.age.keyFile` for system-level secrets |

### 6.6 Home Manager Modules

Home modules follow the identical registry pattern, just under `flake.modules.homeManager.*`. There's no `modules/home/default.nix` aggregator anymore — each host's `home-manager.users.<user>.imports` list (§6.2, item 8) is the only place a home module's inclusion is decided, e.g.:

```nix
# thinkpad-t480 (NixOS)
imports = with self.modules.homeManager; [
  core shell editor git secrets dev desktop onepassword
  browsers media communication ai gaming
  ghostty kitty alacritty
  hyprland theming quickshell qs-brain-shell ambxst
  tide-island caelestia-shell
  kubernetes docker
];

# uw-mac-m1 (darwin)
imports = with self.modules.homeManager; [
  core shell editor git secrets dev
  ghostty kitty alacritty vicinae
  darwin-packages darwin-symlinks
  kubernetes docker aerospace sketchybar
  browsers media communication input onepassword ai
];
```

**`core.nix`** — Always listed. Installs cross-platform build/dev basics: `gcc`, `gnumake`, `stow`, `sops`, `mise`, `rbenv`, `fx`, `jq`, plus `killall`/`nix-ld`/`os-prober` on Linux only.

**`shell.nix`** — Terminal tooling (`tmux`, `starship`, `zoxide`, `fzf`, `bat`, `eza`, `ripgrep`, `fd`, …) plus platform-specific extras (Wayland `matugen`/`awww` on Linux; a long list of CLI tools on darwin where they're not already system-provided). This is also where fish's **per-file** symlinking lives now (see §6.7).

**`dev.nix`** — k9s, lazygit-adjacent dev tooling, language toolchains.

**`desktop.nix`** — Active when `vitorf7.desktop.enable` (checked via `osConfig`). SSH via 1Password agent, Zen browser, fonts, Wayland environment variables.

**`hyprland.nix`** — Active when `vitorf7.desktop.hyprland.enable`. Full Hyprland ecosystem packages + config symlinks; also declares `flake.modules.homeManager.theming` in the same file.

**`darwin-packages.nix` / `darwin-symlinks.nix`** — darwin-only home modules: macOS-specific packages, and `mkOutOfStoreSymlink`-based dotfile links (`bin/`, `.aliases`) plus a `home.activation` hook that clones the `ruby-build` rbenv plugin if missing.

### 6.7 The `mkOutOfStoreSymlink` Pattern — Editable Dotfiles

This is still the key to how dotfiles work, unchanged in mechanism from before the migration — only the file it lives in has moved (mostly into `shell.nix`, `editor.nix`, and platform-specific `*-symlinks.nix` files now, rather than one central `core.nix`):

```nix
# modules/shell.nix
let
  dot = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in {
  xdg.configFile."fish/config.fish".source = link "${dot}/fish/.config/fish/config.fish";
  xdg.configFile."tmux".source             = link "${dot}/tmux/.config/tmux";
}
```

A regular `file.source = ./somefile` would **copy** the file into `/nix/store/` and make it immutable. `mkOutOfStoreSymlink` instead creates a symlink that points *outside* the store — to a path in your live dotfiles repository.

Result: `~/.config/tmux` → `~/dotfiles/tmux/.config/tmux`

You can edit files in `~/dotfiles/` directly and changes take effect immediately without running `nixos-rebuild`/`darwin-rebuild`.

> **Fisher (fish plugin manager).** Fish config is still linked *per-file* (`config.fish`, `aliases.fish`, `fish_plugins`, and individual files under `functions/`) precisely so `~/.config/fish` stays a real writable directory — this makes it fisher-compatible with zero Nix involvement. Bootstrap once per machine:
>
> ```fish
> curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
> ```
>
> Fisher rewrites `fish_plugins` in place (through the symlink), so `fisher install`/`remove` changes land directly in the git-tracked dotfiles file, while plugin sources live as machine-local plain files under `~/.config/fish/{functions,conf.d,completions}`.

---

## 7. Custom Patterns

### 7.1 The `vitorf7.*` Feature Flag System

The system's modularity rests on the shared option tree in `modules/options.nix`. The flow for any feature:

```
modules/options.nix            → declares the option once, assigned to both
                                  flake.modules.nixos.options and flake.modules.darwin.options
    ↓
modules/hosts/*/default.nix    → sets the flag true/false for that specific host
    ↓
modules/<feature>.nix          → flake.modules.nixos.<feature>      = lib.mkIf config.vitorf7.<feature>.enable  { ... }  (system effect)
                                  flake.modules.homeManager.<feature> = lib.mkIf osConfig.vitorf7.<feature>.enable { ... }  (home effect)
```

The `assertions` pattern from before the migration is still alive and well — `modules/qs-brain-shell.nix`'s home-manager half:

```nix
flake.modules.homeManager.qs-brain-shell = { lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.qs_brain_shell.enable {
  assertions = [{
    assertion = osConfig.vitorf7.desktop.quickshell.enable;
    message = "vitorf7.desktop.qs_brain_shell.enable requires vitorf7.desktop.quickshell.enable = true";
  }];
};
```

If you enable `qs_brain_shell` without enabling `quickshell`, the build fails with a clear, human-readable message instead of a cryptic error.

### 7.2 nixos-hardware — Hardware Quirk Library

Rather than copy-pasting hardware-specific tweaks from the NixOS wiki, `thinkpad-t480/default.nix` pulls in nixos-hardware modules directly in its module list — mixing the normal `nixosModules.*` attribute form with one imported by raw string path:

```nix
inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
inputs.nixos-hardware.nixosModules.common-gpu-nvidia
"${inputs.nixos-hardware}/common/gpu/nvidia/pascal"
```

1. **`lenovo-thinkpad-t480`** — BD-PROCHOT thermal throttling fix, TrackPoint scroll emulation, `fstrim` for SSD health.
2. **`common-gpu-nvidia`** — `hardware.nvidia.open = false` (closed-source driver), `services.xserver.videoDrivers = ["nvidia"]`, PRIME offload enabled.
3. **`"${inputs.nixos-hardware}/common/gpu/nvidia/pascal"`** — imported by filesystem path into the flake input rather than a `nixosModules.<name>` attribute, because this particular module isn't (or wasn't) exposed as a named attribute upstream. Sets the driver package to `nvidiaPackages.legacy_580` via `lib.mkDefault`.

The `lib.mkDefault` on the driver is intentional — it lets `modules/nvidia.nix` override it with `legacy_535` using a plain assignment (priority 100 beats `mkDefault`'s 1000). This is the discovered-through-use driver version that actually works on this specific T480.

### 7.3 Custom Derivations: `pkgs/*.nix`

Wired almost entirely through `modules/packages.nix` — the one module in this repo that does **not** follow the `flake.modules.*` registry convention. It's a plain flake-parts `perSystem` block:

```nix
# modules/packages.nix
{ inputs, ... }:
{
  systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
  perSystem = { system, ... }:
    let pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
    in {
      packages = {
        hyprmod     = inputs.hyprmod.packages.${system}.default;   # from its own flake input now, not a local derivation
        tide-island = pkgs.callPackage ../pkgs/tide-island.nix { };
        go-latest   = pkgs.callPackage ../pkgs/go-latest.nix { };
        strongbox   = pkgs.callPackage ../pkgs/strongbox.nix { };
      };
    };
}
```

`import-tree` doesn't require the `flake.modules.*` shape — it imports every file it finds as a flake-parts module regardless of what that module declares, so a plain `perSystem` block like this composes fine alongside the dendritic-style files. It's worth knowing about specifically *because* it's the exception: if you go looking for where a package is exposed and it's not in a `flake.modules.*` assignment, check here.

Two derivations are consumed directly rather than through `packages.nix`:
- `pkgs/wiresteward.nix` — `pkgs.callPackage ../pkgs/wiresteward.nix { }` inline inside `modules/wiresteward.nix`.
- `pkgs/hyprmod.nix` — **superseded**. hyprmod now ships as its own flake (`inputs.hyprmod`), so this file is dead code kept around only for reference; see §10.

`pkgs/mouseless.nix` remains unwired — same "not taken" status as before the migration (Mouseless is installed via Flatpak instead, when `desktop.flatpak.enable` is set).

### 7.4 Non-Dendritic Escape Hatches, Summarised

Two files intentionally break the "everything is `flake.modules.<class>.<name>`" convention, and it's useful to know both by name so you don't go looking for a registry entry that doesn't exist:

- `modules/flake-modules-type.nix` — declares the `flake.modules` option itself (§5.3).
- `modules/packages.nix` — plain `perSystem` package-building block (§7.3).

Everything else in `modules/` (all ~54 remaining files) follows the registry pattern.

### 7.5 The sops-nix Secrets Pattern

Alongside the strongbox-based secret (`secrets/wiresteward-secrets.nix`, unchanged from before the migration — see the root `README.md`'s Secrets section for the strongbox prerequisites), most secrets now go through **sops-nix**. `modules/secrets.nix` is the clearest example, again a dual-class file:

```nix
flake.modules.nixos.secrets = { config, ... }: {
  sops.age.keyFile = "/home/${config.vitorf7.username}/.config/sops/age/keys.txt";
};

flake.modules.homeManager.secrets = { config, pkgs, lib, osConfig, ... }:
  let
    sopsDirFromFlakeRoot = ../sops;
    gitCfg = osConfig.vitorf7.git;
  in {
    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    sops.secrets."gitconfig/personal/name".sopsFile = sopsDirFromFlakeRoot + "/git/personal.yaml";
    sops.secrets."gitconfig/work/name" = lib.mkIf gitCfg.work.enable {
      sopsFile = sopsDirFromFlakeRoot + "/git/work.yaml";
      key = "name";
    };

    sops.templates."git-identity-personal".content = ''
      [user]
      	name = ${config.sops.placeholder."gitconfig/personal/name"}
      	email = ${config.sops.placeholder."gitconfig/personal/email"}
    '';
  };
```

Two things worth noticing:
- **Single key file**: both system-level secrets (like the wiresteward runtime config in `modules/wiresteward.nix`) and home-manager secrets (git identity, sketchybar weather vars) decrypt using the same per-user key at `~/.config/sops/age/keys.txt`. On Linux, root can read this file during system activation. This avoids the need for a separate `sudo`-owned `/etc/sops/age/keys.txt` on new installs.
- **`sops.templates`**: rather than reading secret values directly into Nix config (which would leak them into the world-readable store), `git.nix`'s home-manager half reads `config.sops.templates."git-identity-personal".path` — a path to a file sops-nix assembles *at activation time* by substituting `config.sops.placeholder.*` references into the template content above. The actual secret values never pass through the Nix store.
- Everything here is gated the normal way, via `lib.mkIf gitCfg.work.enable` reading `osConfig.vitorf7.git.work.enable` — the sops-nix modules aren't a special case with respect to the `vitorf7.*` flag system.

---

## 8. Full Trace: The NVIDIA Feature Flag

Tracing `vitorf7.hardware.nvidia.enable = true` from declaration to running GPU, verified against the current files.

**Step 1 — Declaration** (`modules/options.nix`):
```nix
hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
```
This creates the option (shared by both `flake.modules.nixos.options` and `flake.modules.darwin.options`, though only NixOS hosts actually set it true). Without it, setting the flag would be a NixOS type error ("undefined option").

**Step 2 — Setting** (`modules/hosts/thinkpad-t480/default.nix`):
```nix
vitorf7.hardware.nvidia.enable = true;
```
This is the only host that sets this flag to `true`. The VMs leave it at the default `false` and don't even list `self.modules.nixos.nvidia` in their module set.

**Step 3 — Guard check** (`modules/nvidia.nix`):
```nix
flake.modules.nixos.nvidia = { config, lib, ... }: lib.mkIf config.vitorf7.hardware.nvidia.enable {
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;  # overrides nixos-hardware's legacy_580
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;  # disabled: causes crashes with external display
    prime.intelBusId = "PCI:0:2:0";      # must match `lspci` output on this machine
    prime.nvidiaBusId = "PCI:1:0:0";
  };
  hardware.graphics.enable = true;       # required for PRIME; nixos-hardware doesn't set this
};
```

**Step 4 — nixos-hardware interaction**: `thinkpad-t480/default.nix` imports
`"${inputs.nixos-hardware}/common/gpu/nvidia/pascal"` by string path, which uses `lib.mkDefault`
for the driver package (priority 1000). The plain assignment in `modules/nvidia.nix` (priority
100) wins, selecting `legacy_535` over the upstream `legacy_580`.

**Step 5 — Kernel parameters** (`modules/hosts/thinkpad-t480/default.nix`):
```nix
boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
```
Required for Hyprland to use NVIDIA's DRM interface. Set directly in the host's identity block, on top of what nixos-hardware sets.

**Step 6 — DRM device pin** (`modules/hosts/thinkpad-t480/default.nix`):
```nix
environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";
```
PRIME offload shifts the DRM card numbering (the Intel iGPU becomes card0, NVIDIA becomes card1). Hyprland needs to be told which card to use.

**End result**: On the ThinkPad, the Intel HD Graphics 620 (iGPU) drives all displays at low power. Applications launched with `prime-run <app>` use the NVIDIA MX150 (dGPU). The discrete GPU is suspended when idle.

---

## 9. Practical Reference

### Adding a Package to Your User Environment

- **Always installed**: add to `home.packages` in `modules/core.nix` (cross-platform CLI/dev tools) or `modules/dev.nix`
- **Only when a flag is on**: add inside the relevant module's `lib.mkIf osConfig.vitorf7.<flag>.enable { ... }` block (e.g. `modules/desktop.nix`, `modules/hyprland.nix`)
- **System-wide** (available to all users): add to `environment.systemPackages` in a `flake.modules.nixos.*` module

### Adding a System Service

For a new unconditional service: create a file under `modules/`, assign
`flake.modules.nixos.<name> = { ... }: { ... };` (no condition), then add `self.modules.nixos.<name>`
to the relevant host(s)' module list. There is no aggregator file to edit — `import-tree` finds
the new file automatically; the only wiring left is naming it in the host(s) that want it.

For a service gated on an existing flag: wrap the module body in `lib.mkIf config.vitorf7.<flag>.enable { ... }`.

For a brand-new feature (with its own flag):
1. Add the option to `modules/options.nix`'s `vitorf7Options`
2. Create `modules/<myfeature>.nix` with `flake.modules.nixos.<myfeature> = { config, lib, ... }: lib.mkIf config.vitorf7.<myfeature>.enable { ... };`
3. Add `self.modules.nixos.<myfeature>` to the relevant host's module list in `modules/hosts/<host>/default.nix`
4. Set `vitorf7.<myfeature>.enable = true;` in that host's feature-flags block

### Adding a New Host

See the root `README.md`'s "Adding a new host" sections — the short version is: create
`modules/hosts/<name>/default.nix` modelled on an existing host, no `flake.nix` edits needed.

### Updating Packages

```bash
# Update all inputs to their latest commits
nix flake update

# Update only one input
nix flake lock --update-input hyprmod

# Apply the update
sudo nixos-rebuild switch --flake .#<hostname>
# or
sudo darwin-rebuild switch --flake .#<hostname>
```

### Dry Run and Rollback

```bash
# See what would change without applying
sudo nixos-rebuild dry-activate --flake .#<hostname>

# Build but don't switch
sudo nixos-rebuild build --flake .#<hostname>

# Roll back to the previous generation
sudo nixos-rebuild switch --rollback
# darwin equivalent:
sudo darwin-rebuild --rollback
```

---

## 10. What Isn't Here Yet

### nixos-arm-vm / nixos-x86-vm `_hardware-configuration.nix`

Neither ARM nor x86 VM host directory ships a real hardware-configuration file — only `default.nix` exists under `modules/hosts/nixos-arm-vm/` and `modules/hosts/nixos-x86-vm/`. It must be generated on the actual VM before first deploy:

```bash
sudo nixos-generate-config --show-hardware-config > _hardware-configuration.nix
```

This is by design — hardware configs are machine-specific and not portable.

### `pkgs/hyprmod.nix` — Fully Superseded

Unlike the old "wait for a nixpkgs PR to merge" status, this one's resolved differently:
hyprmod now ships as its own flake (`inputs.hyprmod`, `github:vitorf7/hyprmod/nix-flake`), and
`modules/packages.nix` sources the package from `inputs.hyprmod.packages.${system}.default`
directly. `pkgs/hyprmod.nix` and its five inline Python dependency derivations are dead code —
a candidate for outright deletion rather than a "delete once X happens" placeholder.

### `pkgs/mouseless.nix` — the Nix Path Not Taken

Still complete and correct, still unused. Mouseless is installed via Flatpak in
`modules/flatpak.nix` instead. If you wanted to switch to the Nix-native approach:
1. Remove the Flatpak entry from `modules/flatpak.nix`
2. Add `pkgs.callPackage ../pkgs/mouseless.nix {}` to `home.packages` in a home module

### `modules/packages.nix` and `modules/flake-modules-type.nix` as Escape Hatches

Not a gap exactly, but worth remembering: these two files are the only ones in `modules/` that
don't follow the `flake.modules.<class>.<name>` convention (see §7.4). If a future refactor
wants a fully "pure" dendritic tree, these are the two files that would need rethinking.
