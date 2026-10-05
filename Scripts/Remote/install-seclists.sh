#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-seclists_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in ssh whiptail git; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Install SecLists failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

PLUGINNAME=$(whiptail --inputbox "What is the plugin name?" $LINES $COLUMNS "${PLUGINNAME}" --title "Plugin name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    log "User selected Ok and entered $PLUGINNAME"
else
    log "User selected Cancel."
    exit 0
fi

if [ -z "$CURR_CONN" ]; then
    log "ERROR: CURR_CONN is not set, please run one of the Connection Setup scripts first."
    exit 1
fi

if [ "$CURR_CONN" == "BT" ]; then
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "git clone https://github.com/danielmiessler/SecLists"
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "cd SecLists && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
fi
if [ "$CURR_CONN" == "USB" ]; then
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "git clone https://github.com/danielmiessler/SecLists"
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "cd SecLists && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
fi
if [ "$CURR_CONN" == "ETH" ]; then
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "git clone https://github.com/danielmiessler/SecLists"
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "cd SecLists && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
fi
if [ "$CURR_CONN" == "WLAN" ]; then
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "git clone https://github.com/danielmiessler/SecLists"
    ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "cd SecLists && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
fi

log "SecLists installation complete."
