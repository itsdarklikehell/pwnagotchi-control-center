#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Download Image" "Download the latest pwnagotchi image." \
        "Flash Sd" "Flash the pwnagotchi image or zip file to an sd card." \
        "Backup Sd" "Backup an sd card to a flashable image or zip file." \
        "Modify Config" "Modify an config.toml." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $option"
else
    echo "User selected Cancel."
    exit
fi

if [ "$option" == "Download Image" ]; then
    cd "${DOWNLOAD_DIR}" || exit
    if [ ! -f "pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip" ]; then
        echo "Downloading pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip"
        wget -C "https://github.com/evilsocket/pwnagotchi/releases/download/${PWNAGOTCHI_VERSION}/pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip"
    else
        echo "Extracting pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip"
        unzip "pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip"
    fi
fi

if [ "$option" == "Flash Sd" ]; then
    cd "${DOWNLOAD_DIR}" || exit
    if [ ! -f "${SD_DEVICE}" ]; then
        echo "${SD_DEVICE} is not found, make sure the corect value is set in .config/config..."
        exit
    else
        echo "SD_DEVICE is set to ${SD_DEVICE}"
        if [ ! -f pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip ]; then
            echo "${DOWNLOAD_DIR}/${PWNAGOTCHI_VERSION} is not found, download it first and try again..."
            exit
        else
            unzip -p "pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip" | dd of="${SD_DEVICE}" bs=1M
        fi
    fi
fi
