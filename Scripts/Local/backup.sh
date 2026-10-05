#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in dd mount umount whiptail wget; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Backup failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

BACKUP() {
    if [ -z "$SD_DEVICE" ]; then
        log "ERROR: SD_DEVICE is not set, make sure the correct value is set in .config/config..."
        exit 1
    fi
    log "Creating backup of $SD_DEVICE in $BACKUP_DIR/Images/$BACKUP_NAME.img"
    sudo dd if="$SD_DEVICE" of="$BACKUP_DIR/Images/$BACKUP_NAME.img" bs=1M status=progress
    sync
    log "Backup complete."
}

SHRINK() {
    mkdir -p ./Scripts/Local/PiShrink
    cd ./Scripts/Local/PiShrink || exit 1
    wget -c https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    chmod +x pishrink.sh
    sudo cp pishrink.sh /usr/local/bin
    sudo pishrink.sh -ad "$BACKUP_DIR/Images/$BACKUP_NAME.img" "$BACKUP_DIR/Images/$BACKUP_NAME-shrunk.img" && rm "$BACKUP_DIR/Images/$BACKUP_NAME.img"
    log "Shrink complete."
}

UNMOUNT() {
    if [ -z "$SD_DEVICE" ]; then
        log "ERROR: SD_DEVICE is not set, make sure the correct value is set in .config/config..."
        exit 1
    fi
    if (whiptail --title "Are you sure you want to unmount $SD_DEVICE?" --yesno "Unmount check." $LINES $COLUMNS); then
        log "User selected Yes, unmounting $SD_DEVICE"
        sudo umount "$SD_DEVICE"
    else
        log "User selected No, exiting."
        exit 0
    fi
}

BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "$BACKUP_DIR/Images" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $BACKUP_DIR"
else
    log "User selected Cancel."
    exit 0
fi

BACKUP_NAME=$(whiptail --inputbox "What is the Backup name?" $LINES $COLUMNS "$BACKUP_NAME/Images" --title "Backup name." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $BACKUP_NAME"
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

SD_DEVICE=$(whiptail --inputbox "What is the Sd card?" $LINES $COLUMNS "$SD_DEVICE" --title "Sd Card." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $SD_DEVICE"
else
    log "User selected Cancel."
    exit 0
fi

if (whiptail --title "Everything is ready... Start backup process now?" --yesno "Start check." $LINES $COLUMNS); then
    log "User selected Yes, starting backup process."
    UNMOUNT
    sleep 1
    BACKUP
    sleep 1
    SHRINK
else
    log "User selected No, exiting."
    exit 0
fi
