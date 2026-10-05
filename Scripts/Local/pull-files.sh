#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/pull-files_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in mount whiptail cp mkdir; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Pull files failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

MOUNT() {
    cd "$BACKUP_DIR" || exit 1
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

BACKUP_DIR=$(
    whiptail --inputbox "What is the Backup dir to copy to?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $BACKUP_DIR."
else
    log "User selected Cancel."
    exit 0
fi

if command -v hwinfo &>/dev/null; then
    grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short) >/tmp/usblist.txt 2>/dev/null || true
    whiptail --title "Usb List." --textbox /tmp/usblist.txt $LINES $COLUMNS
else
    log "hwinfo not installed, skipping USB list."
fi

SD_DEVICE=$(
    whiptail --inputbox "What is the Sd card to copy to?" $LINES $COLUMNS "$SD_DEVICE" --title "Sd Card." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $SD_DEVICE."
else
    log "User selected Cancel."
    exit 0
fi

FILES=$(
    whiptail --title "Check list example" --checklist \
        "Choose what you want to Pull" $LINES $COLUMNS $(($LINES - 8)) \
        "Handshakes" "Pull handshakes from $ROOT_MOUNT_DIR/$HANDSHAKE_DIR to $BACKUP_DIR/Handshakes" ON \
        "Main Config" "Pull main config.toml from $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml to $BACKUP_DIR/Configs" ON \
        "Plugin Files" "Pull plugin files from $CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins" ON \
        "Plugin Configs" "Pull plugin configs from $CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Configs" ON \
        "User Bin" "Pull user bin from $ROOT_MOUNT_DIR/home/pi/bin to $BACKUP_DIR/Bin" ON \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $FILES."
else
    log "User selected Cancel."
    exit 0
fi

if [[ "$FILES" =~ "Handshakes" ]]; then
    if [ ! -d "$BACKUP_DIR/Handshakes" ]; then
        mkdir -p "$BACKUP_DIR/Handshakes"
    fi
    log "Pulling handshakes from $ROOT_MOUNT_DIR/$HANDSHAKE_DIR to $BACKUP_DIR/Handshakes."
    cp -r "$ROOT_MOUNT_DIR/$HANDSHAKE_DIR/"* "$BACKUP_DIR/Handshakes"
fi

if [[ "$FILES" =~ "Main Config" ]]; then
    if [ ! -d "$BACKUP_DIR/Configs" ]; then
        mkdir -p "$BACKUP_DIR/Configs"
    fi
    log "Pulling main config.toml from $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml to $BACKUP_DIR/Configs/config.toml and /boot/config.toml."
    cp "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml" "$BACKUP_DIR/Configs/config.toml"
    cp "$BOOT_MOUNT_DIR/config.toml" "$BACKUP_DIR/Configs/config.toml"
fi

if [[ "$FILES" =~ "Plugin Files" ]]; then
    if [ ! -d "$BACKUP_DIR/Plugins" ]; then
        mkdir -p "$BACKUP_DIR/Plugins"
    fi
    log "Pulling plugin files from $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins."
    cp -r "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"* "$BACKUP_DIR/Plugins"
fi

if [[ "$FILES" =~ "Plugin Configs" ]]; then
    if [ ! -d "$BACKUP_DIR/Plugins" ]; then
        mkdir -p "$BACKUP_DIR/Plugins"
    fi
    log "Pulling plugin configs from $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins."
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.toml "$BACKUP_DIR/Plugins" 2>/dev/null || true
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.yml "$BACKUP_DIR/Plugins" 2>/dev/null || true
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.yaml "$BACKUP_DIR/Plugins" 2>/dev/null || true
fi

if [[ "$FILES" =~ "User Bin" ]]; then
    if [ ! -d "$BACKUP_DIR/Bin" ]; then
        mkdir -p "$BACKUP_DIR/Bin"
    fi
    log "Pulling files from $ROOT_MOUNT_DIR/home/pi/bin to $BACKUP_DIR/Bin."
    cp -r "$ROOT_MOUNT_DIR/home/pi/bin/"* "$BACKUP_DIR/Bin"
fi

log "Pull files complete."
