#!/bin/bash
set -euo pipefail
# Modify config.toml on the SD card's boot partition

MOUNT() {
    if [ -z "$SD_DEVICE" ]; then
        echo "SD_DEVICE Variable is not set, make sure the correct value is set in .config/config..."
        exit 1
    fi
    if (whiptail --title "Are you sure you want to mount $SD_DEVICE?" --yesno "Mount check." $LINES $COLUMNS); then
        echo "User selected Yes, exit status was $?."
        sudo mount -a
    else
        echo "User selected No, exit status was $?."
        exit 0
    fi
}

MOUNT

# Check if config.toml exists on boot partition
if [ ! -f "$BOOT_MOUNT_DIR/config.toml" ]; then
    whiptail --msgbox "config.toml not found at $BOOT_MOUNT_DIR/config.toml. Make sure the SD card is mounted correctly." 10 60
    exit 1
fi

# Backup existing config
cp "$BOOT_MOUNT_DIR/config.toml" "$BOOT_MOUNT_DIR/config.toml.bak"
echo "Backup created at $BOOT_MOUNT_DIR/config.toml.bak"

# Edit config with nano
nano "$BOOT_MOUNT_DIR/config.toml"

# Copy to root partition if mounted
if [ -d "$ROOT_MOUNT_DIR/etc/pwnagotchi/" ]; then
    cp "$BOOT_MOUNT_DIR/config.toml" "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
    echo "Config also copied to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
fi

echo "Config modification complete."
