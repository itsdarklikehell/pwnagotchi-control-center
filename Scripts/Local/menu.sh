#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/local-menu_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in whiptail; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Local menu failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Download Image" "Download the pwnagotchi image." \
        "Flash Sd" "Flash or restore a pwnagotchi image or zip file to an Sd Card." \
        "Backup Sd" "Backup an sd card to a flashable image or zip file." \
        "Pull Files" "Extract/copy files from the Sd Card." \
        "Modify Config" "Modify an config.toml and store it on te /boot partiton of the Sd Card." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $option"
else
    log "User selected Cancel."
    exit 0
fi

if [ "$option" == "Download Image" ]; then
    ./Scripts/Local/download.sh
fi

if [ "$option" == "Flash Sd" ]; then
    ./Scripts/Local/flash.sh
fi

if [ "$option" == "Backup Sd" ]; then
    ./Scripts/Local/backup.sh
fi

if [ "$option" == "Modify Config" ]; then
    ./Scripts/Local/modconf.sh
fi

if [ "$option" == "Pull Files" ]; then
    ./Scripts/Local/pull-files.sh
fi
