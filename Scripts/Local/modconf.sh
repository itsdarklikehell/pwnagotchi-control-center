#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/modconf_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in mount whiptail; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Config modification failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

MOUNT() {
    if [ -z "$SD_DEVICE" ]; then
        log "ERROR: SD_DEVICE is not set, make sure the correct value is set in .config/config..."
        exit 1
    fi
    if (whiptail --title "Are you sure you want to mount $SD_DEVICE?" --yesno "Mount check." $LINES $COLUMNS); then
        log "User selected Yes, mounting $SD_DEVICE"
        sudo mount -a
    else
        log "User selected No, exiting."
        exit 0
    fi
}

MOUNT

# Check if config.toml exists on boot partition
if [ ! -f "$BOOT_MOUNT_DIR/config.toml" ]; then
    whiptail --msgbox "config.toml not found at $BOOT_MOUNT_DIR/config.toml. Make sure the SD card is mounted correctly." 10 60
    log "ERROR: config.toml not found at $BOOT_MOUNT_DIR/config.toml"
    exit 1
fi

# Backup existing config
cp "$BOOT_MOUNT_DIR/config.toml" "$BOOT_MOUNT_DIR/config.toml.bak"
log "Backup created at $BOOT_MOUNT_DIR/config.toml.bak"

# Edit config with $EDITOR or fallback to nano
EDITOR="${EDITOR:-nano}"
if command -v "$EDITOR" &>/dev/null; then
    "$EDITOR" "$BOOT_MOUNT_DIR/config.toml"
else
    log "WARNING: $EDITOR not found, falling back to nano"
    nano "$BOOT_MOUNT_DIR/config.toml"
fi

# Copy to root partition if mounted
if [ -d "$ROOT_MOUNT_DIR/etc/pwnagotchi/" ]; then
    cp "$BOOT_MOUNT_DIR/config.toml" "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
    log "Config also copied to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
fi

log "Config modification complete."
