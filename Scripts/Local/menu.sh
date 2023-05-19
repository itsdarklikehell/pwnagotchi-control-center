#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Download Image" "Download the latest pwnagotchi image." \
        "Flash Sd" "Flash the pwnagotchi image or zip file to an sd card." \
        "Backup Sd" "Backup an sd card to a flashable image or zip file." \
        "Modify Config" "Modify an config.toml." \
        3>&1 1>&2 2>&3
)

if [ "$option" == "Download Image" ]; then
    cd "${DOWNLOAD_DIR}" || exit
    wget https://github.com/evilsocket/pwnagotchi/releases/download/"${PWNAGOTCHI_VERSION}"/pwnagotchi-raspbian-lite-"${PWNAGOTCHI_VERSION}".zip
fi

if [ "$option" == "Flash Sd" ]; then
    cd "${DOWNLOAD_DIR}" || exit
    unzip -p pwnagotchi-raspbian-lite-"${PWNAGOTCHI_VERSION}".zip #| dd of=/dev/sdb bs=1M
fi
