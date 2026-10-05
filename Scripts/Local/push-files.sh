#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/push-files_$(date '+%F-%T').log"
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
        log "ERROR: Push files failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

MOUNT() {
    cd "${BACKUP_DIR}" || exit 1
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
        "Choose what you want to Push" $LINES $COLUMNS $(($LINES - 8)) \
        "Handshakes" "Push handshakes from $BACKUP_DIR/Handshakes to $ROOT_MOUNT_DIR/$HANDSHAKE_DIR" ON \
        "Main Config" "Push main config.toml from $BACKUP_DIR/Configs to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml" ON \
        "Plugin Files" "Push plugin files from $BACKUP_DIR/Plugins to $CUSTOM_PLUGIN_DIR" ON \
        "Plugin Configs" "Push plugin configs from $BACKUP_DIR/Configs to $CUSTOM_PLUGIN_DIR" ON \
        "User Bin" "Push user bin from $BACKUP_DIR/Bin to /home/pi/bin" ON \
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
    log "Pushing handshakes from $BACKUP_DIR/Handshakes to $ROOT_MOUNT_DIR/$HANDSHAKE_DIR."
    cp -r "$BACKUP_DIR/Handshakes/"* "$ROOT_MOUNT_DIR/$HANDSHAKE_DIR"
fi

if [[ "$FILES" =~ "Main Config" ]]; then
    log "Pushing main config.toml from $BACKUP_DIR/Configs/config.toml to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml and $BOOT_MOUNT_DIR/boot/config.toml."
    cp "$BACKUP_DIR/Configs/config.toml" "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
    cp "$BACKUP_DIR/Configs/config.toml" "$BOOT_MOUNT_DIR/config.toml"
fi

if [[ "$FILES" =~ "Plugin Files" ]]; then
    log "Pushing plugin files from $BACKUP_DIR/Plugins to $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR."
    cp -r "$BACKUP_DIR/Plugins/"* "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR"
fi

if [[ "$FILES" =~ "Plugin Configs" ]]; then
    log "Pushing plugin configs from $BACKUP_DIR/Plugins to $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR."
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.toml 2>/dev/null || true
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.yml 2>/dev/null || true
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/"*.yaml 2>/dev/null || true
fi

if [[ "$FILES" =~ "User Bin" ]]; then
    log "Pushing files from $BACKUP_DIR/Bin to $ROOT_MOUNT_DIR/home/pi/bin."
    cp -r "$BACKUP_DIR/Bin/"* "$ROOT_MOUNT_DIR/home/pi/bin"
fi

log "Push files complete."
