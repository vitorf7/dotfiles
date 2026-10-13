#!/usr/bin/env bash

# IconSelect - switch the GTK icon theme (GTK apps, Qt via platformTheme gtk3,
# flatpaks via the settings portal). The choice lives in the dconf user
# database, which nothing in Nix manages anymore (see
# nixos/nix-config/modules/theming.nix), so it survives rebuilds.
# Usage: iconSelect.sh <theme>
#
# nwg-look / hyprmod do the same thing graphically. Installed themes live in
# the catalog in nixos/nix-config/modules/theming.nix - anything dropped into
# ~/.local/share/icons works as well.

theme="$1"

if [[ -z "$theme" ]]; then
	echo "Usage: iconSelect.sh <theme>" >&2
	exit 1
fi

gsettings set org.gnome.desktop.interface icon-theme "$theme"

echo "Icon theme set to $theme - restart open apps to re-render their icons."
