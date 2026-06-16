# Hyprland Modernization Summary

This document summarizes all the changes and new components added to your Hyprland setup.

## New Components Added

### 1. Avizo (Phase 1) ✅
**What it is:** Visual OSD notifications for volume and brightness changes

**Files Created:**
- `matugen/.config/matugen/templates/matugen-avizo.ini` - Matugen template with gradient styling
- `~/.config/avizo/config.ini` - Auto-generated config (created by matugen)

**Modified:**
- `matugen/.config/matugen/config.toml` - Added avizo template entry
- `hyprland/.config/hypr/modules/keybindings.conf` - Updated volume/brightness keys to use `volumectl`/`lightctl`
- `hyprland/.config/hypr/modules/autostart.conf` - Added `exec-once = avizo-service`

**Features:**
- Gradient progress bar (primary → tertiary colors)
- Top-center positioning
- Matched to your matugen color scheme
- Auto-reloads when you change wallpapers

**Usage:**
- Press volume up/down keys → see gradient OSD
- Press brightness keys → see gradient OSD
- Run `volumectl -u up` or `lightctl up` manually if needed

---

### 2. Fingerprint Authentication (Phase 2) ✅
**What it is:** Unlock hyprlock with your ThinkPad T480 fingerprint reader

**Files Created:**
- `hyprland/.config/hypr/scripts/fingerprint-restart.service` - Systemd service template
- `hyprland/.config/hypr/scripts/setup-fingerprint.sh` - Setup script

**Modified:**
- `hyprland/.config/hypr/hyprlock.conf` - Added fingerprint auth block and status label

**Setup Instructions:**
```bash
# 1. Install required packages
yay -S python-validity fprintd
# Optional: yay -S libfprint-vfs009x-git

# 2. Run the setup script
bash ~/.config/hypr/scripts/setup-fingerprint.sh

# 3. The script will:
#    - Clear existing fingerprints
#    - Enroll your right-index-finger
#    - Verify it works
#    - Install the post-suspend systemd service
```

**Features:**
- Parallel authentication (password OR fingerprint)
- Visual status message on lock screen
- Post-suspend service to fix T480 fingerprint after sleep
- Works with your existing hyprlock matugen theme

**Important:** The T480's fingerprint reader (06cb:009a) requires `python-validity`, not standard `fprintd`.

---

### 3. nwg-dock-hyprland (Phase 3) ✅
**What it is:** Auto-hiding dock at the bottom of the screen

**Files Created:**
- `matugen/.config/matugen/templates/matugen-dock.css` - Matugen-styled CSS template
- `~/.config/nwg-dock-hyprland/style.css` - Auto-generated (created by matugen)

**Modified:**
- `matugen/.config/matugen/config.toml` - Added dock template entry
- `hyprland/.config/hypr/modules/autostart.conf` - Added dock autostart

**Features:**
- Auto-hide: Move mouse to bottom edge to show
- Border highlight on active windows (2px solid primary color)
- Launcher button opens your rofi sidelauncher
- Shows pinned + running applications
- Styled with your matugen colors
- Position: bottom, Icon size: 48px

**Usage:**
- Hover at bottom screen edge → dock appears
- Click app icons → focus/switch
- Click launcher (leftmost) → rofi sidelauncher
- Right-click app → context menu

---

### 4. AGS Status Bar (Phase 4) ✅
**What it is:** Modern GTK4-based status bar with animations and interactivity

**Files Created:** (20+ files in `ags/.config/ags/`)

**Configuration:**
```
ags/.config/ags/
├── app.ts                      # Main entry
├── package.json               # NPM config
├── tsconfig.json              # TypeScript config
├── style/
│   ├── main.scss              # Main stylesheet
│   └── _matugen.generated.scss # Auto-generated colors
└── src/
    ├── widgets/
    │   ├── Bar.ts             # Main bar container
    │   ├── Workspaces.ts      # Clickable workspaces
    │   ├── WindowTitle.ts     # Active window
    │   ├── Clock.ts           # Time display
    │   ├── SystemTray.ts      # Tray icons
    │   ├── Volume.ts          # Volume with scroll
    │   ├── Network.ts         # WiFi/Ethernet
    │   ├── Battery.ts         # Battery with hover info
    │   ├── PowerMenu.ts       # Power button
    │   └── SwayNC.ts          # Notifications toggle
    ├── services/
    │   ├── Matugen.ts         # Color change watcher
    │   ├── Hyprland.ts        # IPC for workspaces/windows
    │   ├── Battery.ts         # Battery monitor
    │   ├── Audio.ts           # Volume monitor
    │   └── Network.ts         # Network monitor
    └── utils/
        └── matugen-colors.ts  # Auto-generated color constants
```

**Matugen Templates:**
- `matugen/.config/matugen/templates/matugen-ags.scss` - SCSS color variables
- `matugen/.config/matugen/templates/matugen-ags-colors.ts` - TypeScript color exports

**Modified:**
- `matugen/.config/matugen/config.toml` - Added 2 AGS template entries
- `hyprland/.config/hypr/modules/autostart.conf` - Added `exec-once = ags`
- `hyprland/.config/hypr/modules/keybindings.conf` - Added AGS reload keybinding

**Features:**
- **Workspaces:** Click to switch, visual active indicator
- **Window Title:** Hover tooltip, scroll to change workspace
- **Clock:** Hover shows date tooltip
- **System Tray:** Click icons, right-click for menus
- **Volume:** Scroll to adjust, click to mute, right-click for pavucontrol
- **Network:** Shows WiFi SSID + signal, click for settings
- **Battery:** Hover shows time remaining, hides if no battery
- **SwayNC:** Click to toggle notification center
- **Power Menu:** Opens wlogout

**Animations:**
- Hover scale effects (1.05x)
- Smooth transitions (0.2s ease)
- Slide-down entrance animation
- Color transitions on state changes

**Layout (matches your waybar):**
```
[Left]                    [Center]              [Right]
Launcher | Clock | Workspaces    Tray | Window    Volume | Network | Battery | SwayNC | Power
```

**Usage:**
- Run alongside waybar for testing
- Press `CTRL + SHIFT + R` to reload AGS during development
- Matugen auto-reloads AGS when colors change

---

## Matugen Integration

All new components are fully integrated with your existing matugen setup:

**When you change wallpapers via vicinae:**
1. vicinae calls matugen with new image
2. matugen regenerates ALL color files:
   - `waybar/colors/colors.css` → `pkill -SIGUSR2 waybar`
   - `swaync/matugen/matugen-swaync.css` → `swaync-client -rs`
   - `avizo/config.ini` → `pkill -USR1 avizo-service`
   - `nwg-dock-hyprland/style.css` → `pkill -SIGUSR1 nwg-dock-hyprland`
   - `ags/style/_matugen.generated.scss` → Compiles SCSS → Reloads AGS
   - `ags/src/utils/matugen-colors.ts` → TypeScript color update
3. All components instantly update to new color scheme

**Templates Added to matugen:**
- `matugen-avizo.ini` → `~/.config/avizo/config.ini`
- `matugen-dock.css` → `~/.config/nwg-dock-hyprland/style.css`
- `matugen-ags.scss` → `~/.config/ags/style/_matugen.generated.scss`
- `matugen-ags-colors.ts` → `~/.config/ags/src/utils/matugen-colors.ts`

---

## Installation Checklist

Run these commands to install all packages:

```bash
# Phase 1: Avizo
yay -S avizo

# Phase 2: Fingerprint (T480)
yay -S python-validity fprintd
# Optional: yay -S libfprint-vfs009x-git

# Phase 3: Dock
yay -S nwg-dock-hyprland

# Phase 4: AGS
yay -S aylurs-gtk-shell

# Install SCSS compiler for AGS
sudo pacman -S sassc

# After installing, run matugen to generate initial configs
matugen -i ~/path/to/your/wallpaper.jpg

# Setup fingerprint
bash ~/.config/hypr/scripts/setup-fingerprint.sh
```

---

## Testing & Verification

### Test Each Component:

**Avizo:**
- Press volume up/down → Should see gradient bar appear at top
- Change brightness → Should see gradient bar
- Colors should match your theme

**Dock:**
- Move mouse to bottom edge → Dock should slide up
- Click launcher → Rofi should open
- Open some apps → Should see icons in dock
- Active window should have colored border

**Fingerprint:**
- Lock screen: `loginctl lock-session`
- Touch fingerprint sensor → Should unlock
- Check status message shows on lock screen
- Suspend/resume → Fingerprint should still work

**AGS:**
- AGS bar should appear at top (alongside waybar during testing)
- Click workspaces → Should switch
- Scroll on volume → Should change volume
- Hover over battery → Should show time remaining
- Change wallpaper → AGS should update colors automatically

---

## Keybindings Added

```ini
# In hyprland/.config/hypr/modules/keybindings.conf

# Hyprpicker - Color picker
bind = $mainMod, C, exec, hyprpicker -a | wl-copy

# AGS reload during development
bind = CTRL SHIFT, R, exec, ags -q; sleep 0.5; ags

# Volume/Brightness (modified to use Avizo)
bindel = ,XF86AudioRaiseVolume, exec, volumectl -u up
bindel = ,XF86AudioLowerVolume, exec, volumectl -u down
bindel = ,XF86AudioMute, exec, volumectl toggle-mute
bindel = ,XF86AudioMicMute, exec, volumectl -m toggle-mute
bindel = ,XF86MonBrightnessUp, exec, lightctl up
bindel = ,XF86MonBrightnessDown, exec, lightctl down
```

---

## Files Modified Summary

**Modified Files (3):**
1. `hyprland/.config/hypr/modules/keybindings.conf`
2. `hyprland/.config/hypr/modules/autostart.conf`
3. `hyprland/.config/hypr/hyprlock.conf`

**Matugen Templates (4 new):**
1. `matugen/.config/matugen/templates/matugen-avizo.ini`
2. `matugen/.config/matugen/templates/matugen-dock.css`
3. `matugen/.config/matugen/templates/matugen-ags.scss`
4. `matugen/.config/matugen/templates/matugen-ags-colors.ts`

**New Scripts (2):**
1. `hyprland/.config/hypr/scripts/fingerprint-restart.service`
2. `hyprland/.config/hypr/scripts/setup-fingerprint.sh`

**AGS Source (15+ files):**
Complete AGS bar implementation in `ags/.config/ags/`

---

## Next Steps

1. **Install packages** (see checklist above)
2. **Run matugen** to generate initial configs for new components
3. **Setup fingerprint** using the setup script
4. **Test each component** individually
5. **Compare AGS vs Waybar** - decide which you prefer
6. **Once satisfied with AGS**, you can remove waybar from autostart

## Troubleshooting

**AGS not starting:**
- Check `ags --version` is installed
- Run `ags` manually to see errors
- Check TypeScript compilation: `cd ~/.config/ags && npm install`

**Fingerprint not working:**
- Ensure `python-validity` is installed (not just fprintd)
- Run `fprintd-verify` to test
- Check `systemctl status python3-validity`

**Dock not appearing:**
- Check `nwg-dock-hyprland` is installed
- Move mouse to exact bottom edge
- Check `~/.config/nwg-dock-hyprland/style.css` exists

**Colors not updating:**
- Run `matugen -i /path/to/image.jpg` manually
- Check template paths in `matugen/config.toml`
- Verify post_hooks work: `pkill -USR1 avizo-service`

---

## Questions?

If anything doesn't work or you want adjustments:
1. Check the component's log/output for errors
2. Verify the matugen template generated the config file
3. Test the post_hook command manually
4. File an issue or ask for help!
