#!/bin/bash
set -euo pipefail
cd "$BACKUP_DIR" || exit
if [ ! -f "pwnagotchi-raspbian-lite-$PWNAGOTCHI_VERSION.zip" ]; then
    echo "Downloading pwnagotchi-raspbian-lite-$PWNAGOTCHI_VERSION.zip"
    wget -c "https://github.com/evilsocket/pwnagotchi/releases/download/$PWNAGOTCHI_VERSION/pwnagotchi-raspbian-lite-$PWNAGOTCHI_VERSION.zip"
else
    echo "Extracting pwnagotchi-raspbian-lite-$PWNAGOTCHI_VERSION.zip"
    unzip "pwnagotchi-raspbian-lite-$PWNAGOTCHI_VERSION.zip"
fi
