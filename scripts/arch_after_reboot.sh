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
    # Configure NVIDIA modules early loading
    print_message "$BLUE" "Configuring NVIDIA modules"
    mkdir -p /etc/modprobe.d
    touch /etc/modprobe.d/nvidia.conf
cat << NVIDIA > /etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
NVIDIA

    # Configure mkinitcpio with encryption hooks

    print_message "$BLUE" "Adding mkinitcpio MODULES"
    sed -i 's/^MODULES.*/MODULES=(btrfs i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

    print_message "$BLUE" "Regenerating initramfs"
    mkinitcpio -P linux
    mkinitcpio -P linux-lts
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
    print_message "$GREEN" "Installation completed successfully!"
}

main
