#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/flash_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in dd mount umount whiptail; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Flash failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

UNMOUNT() {
    cd "${BACKUP_DIR}" || exit 1
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

FLASH() {
    cd "${BACKUP_DIR}" || exit 1
    if [ -z "$SD_DEVICE" ]; then
        log "ERROR: SD_DEVICE is not set, make sure the correct value is set in .config/config..."
        exit 1
    fi
    log "SD_DEVICE value read from .config/config is $SD_DEVICE"
    if [ ! -f "$BACKUP_NAME" ]; then
        log "ERROR: $BACKUP_NAME is not found."
        exit 1
    fi
    log "Flashing $BACKUP_NAME to $SD_DEVICE"
    sudo dd if="$BACKUP_NAME" of="$SD_DEVICE" bs=1M status=progress
    sync
    log "Flash complete."
}

BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $BACKUP_DIR"
else
    log "User selected Cancel."
    exit 0
fi

BACKUP_NAME=$(whiptail --inputbox "What is the Backup name?" $LINES $COLUMNS "$BACKUP_NAME" --title "Backup name." 3>&1 1>&2 2>&3)
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

SD_DEVICE=$(whiptail --inputbox "What is the Sd card to flash to?" $LINES $COLUMNS "$SD_DEVICE" --title "Sd Card." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $SD_DEVICE"
else
    log "User selected Cancel."
    exit 0
fi

if (whiptail --title "Everything is ready... Start flash process now?" --yesno "Start check." $LINES $COLUMNS); then
    log "User selected Yes, starting flash process."
    UNMOUNT
    sleep 1
    FLASH
else
    log "User selected No, exiting."
    exit 0
fi
