#!/bin/bash
# T480-specific configuration script for ThinkPad T480
# Run manually after first boot: ./scripts/t480_setup.sh
# This script configures audio and other T480-specific settings

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_DIR="$HOME/dotfiles"

# Function to print colored messages
print_message() {
	local color=$1
	local message=$2
	echo -e "${color}${message}${NC}"
}

# Check if running on T480
check_t480() {
	PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "Unknown")
	if [[ "$PRODUCT_NAME" != *"T480"* ]]; then
		print_message "$RED" "This script is for ThinkPad T480 only."
		print_message "$YELLOW" "Detected: $PRODUCT_NAME"
		exit 1
	fi
	print_message "$GREEN" "ThinkPad T480 detected - applying configurations..."
}

# Create necessary directories
setup_directories() {
	print_message "$BLUE" "Creating configuration directories..."

	mkdir -p ~/.config/easyeffects/output
	mkdir -p ~/.config/easyeffects/autoload/output
	mkdir -p ~/.local/bin
	mkdir -p ~/.config/systemd/user

	print_message "$GREEN" "Directories created."
}

# Setup EasyEffects with T480 preset
setup_easyeffects() {
	print_message "$BLUE" "Setting up EasyEffects for T480..."

	# Enable EasyEffects service
	systemctl --user enable easyeffects.service 2>/dev/null || true

	# Copy T480 EQ preset
	if [ -f "$REPO_DIR/configs/t480/T480-ALC257-Fix.json" ]; then
		cp "$REPO_DIR/configs/t480/T480-ALC257-Fix.json" ~/.config/easyeffects/output/
		print_message "$GREEN" "T480 EQ preset installed."
	else
		print_message "$RED" "T480 EQ preset not found in $REPO_DIR/configs/t480/"
		exit 1
	fi

	# Create autoload configuration
	cat >~/.config/easyeffects/autoload/output/autoload.json <<'EOF'
{
    "output": {
        "T480-ALC257-Fix": {
            "device": "alsa_output.pci-0000_00_1f.3.analog-stereo",
            "profile": "T480-ALC257-Fix"
        }
    }
}
EOF
	print_message "$GREEN" "EasyEffects autoload configured."

	# Copy audio fix script
	if [ -f "$REPO_DIR/configs/t480/t480-audio-fix.sh" ]; then
		cp "$REPO_DIR/configs/t480/t480-audio-fix.sh" ~/.local/bin/
		chmod +x ~/.local/bin/t480-audio-fix.sh
		print_message "$GREEN" "Audio fix script installed."
	else
		print_message "$RED" "Audio fix script not found in $REPO_DIR/configs/t480/"
		exit 1
	fi

	# Create systemd service for audio fix
	cat >~/.config/systemd/user/t480-audio-fix.service <<'EOF'
[Unit]
Description=T480 ALC257 Audio Fix
After=pipewire.service pipewire-pulse.service

[Service]
Type=oneshot
ExecStart=%h/.local/bin/t480-audio-fix.sh
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

	# Enable the service
	systemctl --user daemon-reload
	systemctl --user enable t480-audio-fix.service

	# Run the audio fix now
	~/.local/bin/t480-audio-fix.sh

	print_message "$GREEN" "EasyEffects setup complete."
}

# Configure ALSA for ALC257 codec
setup_alsa() {
	print_message "$BLUE" "Configuring ALSA for ALC257 codec..."
	print_message "$YELLOW" "This requires sudo privileges."

	# Copy ALSA configuration to system
	if [ -f "$REPO_DIR/configs/t480/90-t480-audio.conf" ]; then
		sudo cp "$REPO_DIR/configs/t480/90-t480-audio.conf" /etc/alsa/conf.d/
		print_message "$GREEN" "ALSA configuration installed."
	else
		print_message "$RED" "ALSA config not found in $REPO_DIR/configs/t480/"
		exit 1
	fi

	# Copy kernel module options
	if [ -f "$REPO_DIR/configs/t480/alc257-audio.conf" ]; then
		sudo cp "$REPO_DIR/configs/t480/alc257-audio.conf" /etc/modprobe.d/
		print_message "$GREEN" "Kernel module options installed."
	else
		print_message "$RED" "Kernel module config not found in $REPO_DIR/configs/t480/"
		exit 1
	fi

	print_message "$YELLOW" "ALSA configuration applied."
	print_message "$YELLOW" "Note: A reboot is required to apply kernel module options."
}

# Main installation process
main() {
	print_message "$GREEN" "=========================================="
	print_message "$GREEN" "ThinkPad T480 Setup Script"
	print_message "$GREEN" "=========================================="
	echo ""

	check_t480
	setup_directories
	setup_easyeffects
	setup_alsa

	echo ""
	print_message "$GREEN" "=========================================="
	print_message "$GREEN" "T480 setup complete!"
	print_message "$GREEN" "=========================================="
	echo ""
	print_message "$BLUE" "Next steps:"
	echo "  1. Reboot your system to apply kernel module changes"
	echo "  2. EasyEffects will auto-start with Hyprland"
	echo "  3. Audio should no longer sound muffled/boxy"
	echo ""
	print_message "$BLUE" "To manually adjust EQ settings:"
	echo "  easyeffects &"
	echo ""
	print_message "$YELLOW" "Note: EasyEffects and LSP plugins should already"
	print_message "$YELLOW" "be installed from the main installation script."
}

# Start the setup process
main
