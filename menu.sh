#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/main-menu_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in whiptail git; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Main menu failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

# Set terminal size for whiptail dialogs
if command -v resize &>/dev/null; then
    eval "$(resize)" 2>/dev/null || true
fi
export COLUMNS LINES
# shellcheck source=/dev/null
source .config/config

option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Local Stuff" "Scripts to run locally (ie. Flash or backup an sd card or edit and apply a config.toml to or from a mounted card)." \
        "Remote Stuff" "Setup connection and run scripts on a remotely running pwnagotchi via ssh over usb/eth/bt-pan/wifi(ap)." \
        "Update" "update this script." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $option"
else
    log "User selected Cancel."
    exit 0
fi

if [ "$option" == "Local Stuff" ]; then
    ./Scripts/Local/menu.sh
fi

if [ "$option" == "Remote Stuff" ]; then
    ./Scripts/Remote/menu.sh
fi

if [ "$option" == "Update" ]; then
    git pull origin main
fi
