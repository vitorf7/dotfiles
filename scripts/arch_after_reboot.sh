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

nvidia_setup() {
    # Configure NVIDIA modules early loading
    print_message "$BLUE" "Configuring NVIDIA modules"
    mkdir -p /etc/modprobe.d
cat << NVIDIA > /etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
NVIDIA

    # Configure mkinitcpio with encryption hooks

    print_message "$BLUE" "Adding mkinitcpio MODULES"
    sed -i 's/^MODULES.*/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

    print_message "$BLUE" "Regenerating initramfs"
    mkinitcpio -P linux
    mkinitcpio -P linux-lts
}

setup_timeshift_grub_btrfs() {
    print_message "$BLUE" "Setting up timeshift-autosnap and grub-btrfs"

    yay -S --noconfirm timeshift-autosnap

    sed -i 's/updateGrub.*/updateGrub=false/' /etc/timeshift-autosnap.conf

    sed -i 's%ExecStart.*%ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto%' /etc/systemd/system/grub-btrfsd.service

    print_message "$GREEN" "Setting up timeshift-autosnap and grub-btrfs completed."
}

main() {
    print_message "$GREEN" "Starting Arch Linux after reboot installation..."
    nvidia_setup
    setup_timeshift_grub_btrfs
    print_message "$GREEN" "Installation completed successfully!"
}

main
