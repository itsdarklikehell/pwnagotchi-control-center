#!/bin/bash
set -euo pipefail

# Logging
LOG_DIR="${BACKUP_DIR:-$PWD}/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/download_$(date '+%F-%T').log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

log() {
    echo "[$(date '+%F %T')] $*"
}

# Check dependencies
for cmd in wget unzip; do
    if ! command -v "$cmd" &>/dev/null; then
        log "ERROR: $cmd is not installed. Please install it first."
        exit 1
    fi
done

# Cleanup trap
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: Download failed with exit code $exit_code"
    fi
    exit $exit_code
}
trap cleanup EXIT

cd "${BACKUP_DIR:-$PWD}" || exit 1

IMAGE_ZIP="pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip"
IMAGE_DIR="${IMAGE_ZIP%.zip}"

if [ ! -f "$IMAGE_ZIP" ] && [ ! -d "$IMAGE_DIR" ]; then
    log "Downloading $IMAGE_ZIP"
    wget -c "https://github.com/evilsocket/pwnagotchi/releases/download/${PWNAGOTCHI_VERSION}/${IMAGE_ZIP}"
else
    log "Image already downloaded, skipping download."
fi

if [ -f "$IMAGE_ZIP" ] && [ ! -d "$IMAGE_DIR" ]; then
    log "Extracting $IMAGE_ZIP"
    unzip -q "$IMAGE_ZIP"
fi

log "Download complete."
