#!/bin/bash
# Automated Arch Linux Installation Script
# Requirements:
# - Intel CPU
# - Intel and Nvidia GPU
# - LUKS encryption on root partition
# - BTRFS filesystem for root partition
# - FAT32 for Boot partition
# - Bluetooth, NetworkManager, GNOME, Pipewire
# - GRUB bootloader
# - Timeshift
# - Zram

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables with default values
HOSTNAME="archbtw"
TIMEZONE="Europe/London" # Change to your timezone
KEYMAP="uk" # Change to your keymap
LOCALE="en_GB.UTF-8" # Change to your locale
USERNAME="archuser"
ROOT_PASSWORD=""
USER_PASSWORD=""
DISK=""
BOOT_SIZE=1024 # Size in MiB
LUKS_NAME="cryptroot"

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to prompt for essential configuration
get_user_config() {
    print_message "$GREEN" "Welcome to the Arch Linux Installer!"
    print_message "$BLUE" "Please provide the following information:"
    
    # Get username
    read -p "Enter your username: " input_username
    if [ -n "$input_username" ]; then
        USERNAME="$input_username"
    else
        print_message "$YELLOW" "Using default username: $USERNAME"
    fi
    
    # Get root password
    while [ -z "$ROOT_PASSWORD" ]; do
        read -s -p "Enter root password: " input_root_password
        echo
        if [ -z "$input_root_password" ]; then
            print_message "$RED" "Root password cannot be empty!"
        else
            read -s -p "Confirm root password: " input_root_password_confirm
            echo
            if [ "$input_root_password" = "$input_root_password_confirm" ]; then
                ROOT_PASSWORD="$input_root_password"
            else
                print_message "$RED" "Passwords do not match! Try again."
            fi
        fi
    done
    
    # Get user password
    while [ -z "$USER_PASSWORD" ]; do
        read -s -p "Enter password for user $USERNAME: " input_user_password
        echo
        if [ -z "$input_user_password" ]; then
            print_message "$RED" "User password cannot be empty!"
        else
            read -s -p "Confirm user password: " input_user_password_confirm
            echo
            if [ "$input_user_password" = "$input_user_password_confirm" ]; then
                USER_PASSWORD="$input_user_password"
            else
                print_message "$RED" "Passwords do not match! Try again."
            fi
        fi
    done
    
    # Get target disk
    print_message "$BLUE" "Available disks:"
    lsblk -d -p -n -l -o NAME,SIZE,MODEL | grep -v "loop"
    
    while [ -z "$DISK" ]; do
        read -p "Enter the disk to install Arch Linux on (e.g., /dev/sda): " input_disk
        if [ -b "$input_disk" ]; then
            DISK="$input_disk"
        else
            print_message "$RED" "Invalid disk! Please enter a valid disk path."
        fi
    done
 
    # Optional: Ask for hostname
    read -p "Enter hostname [default: $HOSTNAME]: " input_hostname
    if [ -n "$input_hostname" ]; then
        HOSTNAME="$input_hostname"
    fi
    
    # Optional: Ask for timezone
    read -p "Enter timezone [default: $TIMEZONE]: " input_timezone
    if [ -n "$input_timezone" ]; then
        if [ -f "/usr/share/zoneinfo/$input_timezone" ]; then
            TIMEZONE="$input_timezone"
        else
            print_message "$YELLOW" "Invalid timezone. Using default: $TIMEZONE"
        fi
    fi
    
    # Show configuration summary
    print_message "$GREEN" "Configuration Summary:"
    echo "Username: $USERNAME"
    echo "Hostname: $HOSTNAME"
    echo "Timezone: $TIMEZONE"
    echo "Target Disk: $DISK"
    
    # Confirm configuration
    read -p "Is this configuration correct? (y/n): " confirm_config
    if [[ ! "$confirm_config" =~ ^[Yy]$ ]]; then
        print_message "$RED" "Configuration cancelled. Please start over."
        exit 1
    fi
}

# Function to check if script is run with root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_message "$RED" "This script must be run as root"
        exit 1
    fi
}

# Function to check if booted in UEFI mode
check_uefi() {
    if [ ! -d "/sys/firmware/efi/efivars" ]; then
        print_message "$RED" "System not booted in UEFI mode!"
        exit 1
    fi
}

check_internet() {
    if ! ping -c 2 archlinux.org &> /dev/null; then
        print_message "$RED" "No internet connection detected!"
        exit 1
    fi
}

# Function to confirm before proceeding
confirm() {
    print_message "$RED" "WARNING: This will ERASE ALL DATA on $DISK!"
    read -p "Are you sure you want to proceed? (y/n): " choice
    case "$choice" in
        y|Y ) return 0;;
        * ) return 1;;
    esac
}

installer_initial_setup() {
  loadkeys $KEYMAP

  # Update mirrorlist with reflector
  print_message "$BLUE" "Updating Mirrorlist with Reflector"
  pacman -Sy --noconfirm reflector

  reflector --country 'United Kingdom' --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
  print_message "$BLUE" "Mirrorlist updated with fastest mirrors."

  # Update timezone
  print_message "$BLUE" "Update timezone"
  timedatectl set-timezone $TIMEZONE
  timedatectl set-ntp true
}

# Function to prepare disk
prepare_disk() {
    print_message "$BLUE" "Preparing disk $DISK..."

    if ! confirm; then
        print_message "$RED" "Installation aborted."
        exit 1
    fi
     
    read -p "Will this be installed as a dual booted system? (y/n): " confirm_dualboot
    if [[ "$confirm_dualboot" =~ ^[Yy]$ ]]; then
      print_message "$BLUE" "Dual boot detected. Please manually partition the disk first."
      cfdisk $DISK

      # Get target disk
      print_message "$BLUE" "Available disks:"
      lsblk

      read -p "Enter the boot parition address (e.g., /dev/sda1): " boot_partition_addr
      BOOT_PARTITION="$boot_partition_addr"

      read -p "Enter the root parition address (e.g., /dev/sda2): " root_partition_addr
      ROOT_PARTITION="$root_partition_addr"

    else
      # Create partition table
      parted -s "$DISK" mklabel gpt

      partition_disk

      # Derive partition names from disk path
      if [[ "$DISK" =~ "nvme" ]]; then
          BOOT_PARTITION="${DISK}p1"
          ROOT_PARTITION="${DISK}p2"
      else
          BOOT_PARTITION="${DISK}1"
          ROOT_PARTITION="${DISK}2"
      fi
    fi

    echo "Boot Partition: $BOOT_PARTITION"
    echo "Root Partition: $ROOT_PARTITION"
    
    # Confirm configuration
    read -p "Is this disk configuration correct? (y/n): " confirm_disk_config
    if [[ ! "$confirm_disk_config" =~ ^[Yy]$ ]]; then
        print_message "$RED" "Configuration cancelled. Please start over."
        exit 1
    fi
    
    # Format boot partition
    print_message "$BLUE" "Formatting boot partition..."
    mkfs.fat -F32 "$BOOT_PARTITION"
    
    # Setup LUKS encryption
    print_message "$BLUE" "Setting up LUKS encryption on root partition..."
    cryptsetup luksFormat "$ROOT_PARTITION"
    cryptsetup luksOpen "$ROOT_PARTITION" "$LUKS_NAME"
    
    # Create BTRFS filesystem
    print_message "$BLUE" "Creating BTRFS filesystem..."
    mkfs.btrfs -f "/dev/mapper/$LUKS_NAME"
    
    # Mount BTRFS and create subvolumes
    mount "/dev/mapper/$LUKS_NAME" /mnt
    
    # Create BTRFS subvolumes
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    btrfs subvolume create /mnt/@var_log
    
    # Unmount
    umount /mnt
    
    # Mount subvolumes
    mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@ "/dev/mapper/$LUKS_NAME" /mnt
    mkdir -p /mnt/{boot,home,.snapshots,var/log}
    mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@home "/dev/mapper/$LUKS_NAME" /mnt/home
    mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@snapshots "/dev/mapper/$LUKS_NAME" /mnt/.snapshots
    mount -o noatime,ssd,compress=zstd,space_cache=v2,discard=async,subvol=@var_log "/dev/mapper/$LUKS_NAME" /mnt/var/log
    
    # Mount boot partition
    mount "$BOOT_PARTITION" /mnt/boot

    print_message "$BLUE" "Disk configuration mounted..."
    lsblk
}

partition_disk() {
    # Create boot partition
    parted -s "$DISK" mkpart boot fat32 1MiB ${BOOT_SIZE}MiB
    parted -s "$DISK" set 1 boot on

    # Create root partition
    parted -s "$DISK" mkpart root ${BOOT_SIZE}MiB 100%
}

# Function to install base system
install_base() {
    print_message "$BLUE" "Installing base system..."
    pacstrap /mnt base base-devel linux linux-firmware linux-headers linux-lts linux-lts-headers
   
    # Generate fstab
    genfstab -U /mnt >> /mnt/etc/fstab

    print_message "$BLUE" "FSTab"
    cat /mnt/etc/fstab
}

# Function to configure system
configure_system() {
    print_message "$BLUE" "Configuring the system..."

    print_message "$BLUE" "Set up Reflector"
    
arch-chroot /mnt cat << EOFCHROOT > /etc/xdg/reflector/reflector.conf
# Reflector configuration file for the systemd service
--save /etc/pacman.d/mirrorlist
--country 'United Kingdom'
--protocol https
--latest 20
--sort rate
EOFCHROOT

    arch-chroot /mnt pacman -Syy
    
    # Set timezone
    arch-chroot /mnt ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    arch-chroot /mnt hwclock --systohc
    
    # Set locale
    arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/" /etc/locale.gen
    arch-chroot /mnt locale-gen
    echo "LANG=$LOCALE" > /mnt/etc/locale.conf
    
    # Set keymap
    # echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf
    
    # Set hostname
    echo "$HOSTNAME" > /mnt/etc/hostname
    cat > /mnt/etc/hosts << EOF
127.0.0.1    localhost
::1          localhost
127.0.1.1    $HOSTNAME.localdomain    $HOSTNAME
EOF

    # Configure root password
    print_message "$BLUE" "Setting root password..."
    echo "root:$ROOT_PASSWORD" | arch-chroot /mnt chpasswd
    
    # Add user
    print_message "$BLUE" "Creating user $USERNAME..."
    arch-chroot /mnt useradd -m -g users -G wheel "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd

    # Install sudo
    arch-chroot /mnt pacman -S --noconfirm sudo
    
    # Configure sudo
    arch-chroot /mnt echo "$USERNAME ALL=(ALL) ALL" >> "/etc/sudoers.d/$USERNAME"
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

    print_message "$BLUE" "Installing additional packages..."
    
    arch-chroot /mnt pacman -S \
      btrfs-progs grub grub-btrfs efibootmgr networkmanager network-manager-applet \
      openssh git iptables-nft ipset firewalld acpid reflector \
      intel-ucode mesa gnome gnome-tweaks gnome-extra gdm \
      wayland hyprland hyprpaper hyprlock wofi \
      man-db man-pages man texinfo bluez bluez-utils \
      pipewire alsa-utils pipewire-pulse pipewire-jack pipewire-alsa \
      neovim git tmux fish fzf zram-generator \
      intel-media-driver libva-intel-driver \
      nvidia nvidia-settings nvidia-utils nvidia-lts lib32-nvidia-utils \
      xdg-utils xdg-user-dirs \
      kitty firefox go egl-wayland
    
    # Configure mkinitcpio with encryption hooks

    print_message "$BLUE" "Adding mkinitcpio MODULES"
    arch-chroot /mnt sed -i 's/^MODULES.*/MODULES=(btrfs)/' /etc/mkinitcpio.conf
    print_message "$BLUE" "Adding mkinitcpio HOOKS"
    arch-chroot /mnt sed -i 's/filesystems fsck/encrypt filesystems fsck/' /etc/mkinitcpio.conf

    print_message "$BLUE" "Generating mkinitcpio"
    arch-chroot /mnt mkinitcpio -P linux
    arch-chroot /mnt mkinitcpio -P linux-lts
}

# Function to install GRUB bootloader
install_bootloader() {
    print_message "$BLUE" "Installing GRUB bootloader..."

    # Install GRUB to EFI directory
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

    # Generate GRUB configuration
    print_message "$BLUE" "Generate grub config"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    
    print_message "$BLUE" "Changing GRUB_CMDLINE_LINUX_DEFAULT in Grub"
    # Get UUID of the LUKS partition
    ROOT_UUID=$(blkid -s UUID -o value "$ROOT_PARTITION")
    arch-chroot /mnt sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$ROOT_UUID:$LUKS_NAME root=\/dev\/mapper\/$LUKS_NAME\"/" /etc/default/grub

    # Generate GRUB configuration
    print_message "$BLUE" "Generate grub config"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

    print_message "$BLUE" "Enabling OS Prober"
    arch-chroot /mnt sed -i 's/#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
    
    # Generate GRUB configuration
    print_message "$BLUE" "Generate grub config"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
}

# Function to set up zram-generator
setup_zram() {
    print_message "$BLUE" "Setting up zram-generator..."
    
    # Create zram-generator configuration
    mkdir -p /mnt/etc/systemd/zram-generator.conf.d
    cat > /mnt/etc/systemd/zram-generator.conf.d/zram.conf << EOF
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
swap-priority = 100
EOF

    # Enable zram-generator service
    arch-chroot /mnt systemctl daemon-reload
    arch-chroot /mnt systemctl start /dev/zram0
    arch-chroot /mnt zramctl
    
    print_message "$GREEN" "zram-generator configured."
}

# Function to enable multilib repository
enable_multilib() {
    print_message "$BLUE" "Enabling multilib repository..."
    
    # Uncomment multilib section in pacman.conf
    arch-chroot /mnt sed -i '/\[multilib\]/,/Include/ s/^#//' /etc/pacman.conf
    
    # Update package database
    arch-chroot /mnt pacman -Sy
    
    print_message "$GREEN" "Multilib repository enabled."
}

# Function to install yay AUR helper
install_yay() {
    print_message "$BLUE" "Installing yay AUR helper..."
    
    # Clone, build, and install yay (as the non-root user)
    arch-chroot /mnt bash -c "mkdir -p /tmp/yay-install && cd /tmp/yay-install && \
        git clone https://aur.archlinux.org/yay.git && \
        chown -R $USERNAME:wheel yay && \
        cd yay && \
        sudo -u $USERNAME makepkg -si --noconfirm"
    
    # Clean up temporary files
    arch-chroot /mnt bash -c "rm -rf /tmp/yay-install"
    
    print_message "$GREEN" "yay AUR helper installed."
}

install_aur_packages() {
    print_message "$BLUE" "Installing yay AUR packages..."

    arch-chroot /mnt sudo -u $USERNAME yay -S --noconfirm ghostty zen-browser-bin

    print_message "$GREEN" "yay AUR packages installed."
}

setup_gaming_essentials() {
  print_message "$BLUE" "Setting up gaming essentials..."

  arch-chroot /mnt pacman -S --noconfirm lib32-mesa lib32-vulkan-intel \
    lib32-libva-mesa-driver lib32-mesa-vdpau steam flatpak gamemode goverlay

  print_message "$BLUE" "Install bottles through flatpak"
  arch-chroot /mnt flatpak install flathub com.usebottles.bottles

  arch-chroot /mnt sudo -u $USERNAME yay -S --noconfirm proton-ge-custom-bin

  print_message "$GREEN" "Setting up gaming essentials completed..."
}

# Enabling services
enabling_services() {
    print_message "$BLUE" "Enabling services..."

    # Enable services
    arch-chroot /mnt systemctl enable NetworkManager
    arch-chroot /mnt systemctl enable bluetooth
    arch-chroot /mnt systemctl enable gdm
    arch-chroot /mnt systemctl enable fstrim.timer
    arch-chroot /mnt systemctl enable reflector.timer
    arch-chroot /mnt systemctl enable reflector.service
    arch-chroot /mnt systemctl enable sshd
    arch-chroot /mnt systemctl enable firewalld
    arch-chroot /mnt systemctl enable acpid
    arch-chroot /mnt systemctl enable systemd-zram-setup@zram0.service
    arch-chroot /mnt systemctl enable grub-btrfsd

    print_message "$GREEN" "Services enabled..."
}

# Main installation process
main() {
    print_message "$GREEN" "Starting Arch Linux installation..."
    
    check_root
    check_uefi
    check_internet
    get_user_config
    
    prepare_disk
    install_base
    enable_multilib
    configure_system
    install_bootloader
    setup_zram
    install_yay 
    install_aur_packages
    setup_gaming_essentials
    enabling_services
    
    print_message "$GREEN" "Installation completed successfully!"
    print_message "$YELLOW" "Please reboot your system."
}

# Start the installation process
main
