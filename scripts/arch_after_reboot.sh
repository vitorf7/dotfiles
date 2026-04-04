#!/bin/bash
# - Timeshift
# - Nvidia setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

USERNAME="archuser"

# Function to print colored messages
print_message() {
	local color=$1
	local message=$2
	echo -e "${color}${message}${NC}"
}

# Function to check if script is run with root privileges
check_root() {
	if [[ $EUID -ne 0 ]]; then
		print_message "$RED" "This script must be run as root"
		exit 1
	fi
}

set_env_vars() {
	print_message "$BLUE" "Please provide the following information:"

	# Get username
	read -p "Enter your username: " input_username
	if [ -n "$input_username" ]; then
		USERNAME="$input_username"
	else
		print_message "$YELLOW" "Using default username: $USERNAME"
	fi
}

nvidia_setup() {
	# Configure NVIDIA modules for Pascal (MX150) with PRIME support
	print_message "$BLUE" "Configuring NVIDIA Pascal (MX150) with Intel PRIME..."

	# Install nvidia-prime utilities
	print_message "$BLUE" "Installing nvidia-prime utilities"
	pacman -S --noconfirm nvidia-prime

	# Create modprobe configuration for NVIDIA
	print_message "$BLUE" "Creating NVIDIA modprobe configuration"
	mkdir -p /etc/modprobe.d
	cat <<NVIDIA >/etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
NVIDIA

	# Create PRIME environment variables for render offload
	print_message "$BLUE" "Creating PRIME render offload environment variables"
	mkdir -p /etc/environment.d
	cat <<PRIME >/etc/environment.d/90-nvidia-prime.conf
# PRIME Render Offload for NVIDIA + Intel hybrid graphics
__GLX_VENDOR_LIBRARY_NAME=nvidia
__NV_PRIME_RENDER_OFFLOAD=1
__NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
PRIME

	# Configure mkinitcpio with Intel i915 and NVIDIA modules
	print_message "$BLUE" "Adding mkinitcpio MODULES (i915 + NVIDIA Pascal)"
	sed -i 's/^MODULES.*/MODULES=(btrfs i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

	print_message "$BLUE" "Regenerating initramfs for all kernels"
	mkinitcpio -P linux
	mkinitcpio -P linux-lts

	print_message "$GREEN" "NVIDIA Pascal + PRIME configuration complete!"
	print_message "$YELLOW" "Usage: prime-run <application> or set __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia <application>"
}

setup_timeshift_grub_btrfs() {
	print_message "$BLUE" "Setting up timeshift-autosnap and grub-btrfs"

	sudo -u $USERNAME yay -S --noconfirm timeshift timeshift-autosnap

	sed -i 's/updateGrub.*/updateGrub=false/' /etc/timeshift-autosnap.conf

	EDITOR=nvim systemctl edit --full grub-btrfsd

	sed -i 's%ExecStart.*%ExecStart=/usr/bin/grub-btrfsd --syslog -t%' /etc/systemd/system/grub-btrfsd.service

	systemctl daemon-reload
	systemctl restart grub-btrfsd
	systemctl status grub-btrfsd

	grub-mkconfig -o /boot/grub/grub.cfg

	print_message "$GREEN" "Setting up timeshift-autosnap and grub-btrfs completed."
}

main() {
	print_message "$GREEN" "Starting Arch Linux after reboot installation..."
	check_root
	nvidia_setup
	setup_timeshift_grub_btrfs

	# Check if T480 and remind user
	PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
	if [[ "$PRODUCT_NAME" == *"T480"* ]]; then
		print_message "$YELLOW" "ThinkPad T480 detected!"
		print_message "$BLUE" "Please run: ./scripts/t480_setup.sh"
		print_message "$BLUE" "This will configure audio and other T480-specific settings."
	fi

	print_message "$GREEN" "Installation completed successfully!"
}

main
