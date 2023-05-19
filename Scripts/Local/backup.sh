#!/bin/bash
BACKUP_NAME=$PWNAGOTCHI_HOSTNAME-$PWNAGOTCHI_VERSION-$(date '+%F-%T')

BACKUP() {
    echo "Creating backup of ${SD_DEVICE} in $BACKUP_DIR/${BACKUP_NAME}.img"
    sudo dd if=/dev/"${SD_DEVICE}" of="$BACKUP_DIR/${BACKUP_NAME}.img" bs=1M status=progress
    sync
}
SHRINK() {
    mkdir ./Scripts/Local/PiShrink
    cd ./Scripts/Local/PiShrink || exit
    wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    chmod +x pishrink.sh
    sudo cp pishrink.sh /usr/local/bin
    sudo pishrink.sh -ad "$BACKUP_DIR/${BACKUP_NAME}.img" "${BACKUP_NAME}-shrunk.img"
}
UNMOUNT() {
    if (whiptail --title "Are you sure you want to unmount ${SD_DEVICE}?" --yesno "Unmount check." $LINES $COLUMNS); then
        echo "User selected Yes, exit status was $?."
        sudo umount /dev/"${SD_DEVICE}"
    else
        echo "User selected No, exit status was $?."
        exit
    fi
}

BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "${BACKUP_DIR}" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR"
else
    echo "User selected Cancel."
    exit
fi

BACKUP_NAME=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "${BACKUP_NAME}" --title "Backup name." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_NAME"
else
    echo "User selected Cancel."
    exit
fi
sudo apt install hwinfo
grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short) >/tmp/usblist.txt
whiptail --title "Usb List." --textbox /tmp/usblist.txt $LINES $COLUMNS
SD_DEVICE=$(whiptail --inputbox "What is the Sd card?" $LINES $COLUMNS "${SD_DEVICE}" --title "Sd Card." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $SD_DEVICE"
else
    echo "User selected Cancel."
    exit
fi
if (whiptail --title "Everything is ready... Start backup process now?" --yesno "Start check." $LINES $COLUMNS); then
    echo "User selected Yes, exit status was $?."
    UNMOUNT
    sleep 1
    BACKUP
    sleep 1
    SHRINK
else
    echo "User selected No, exit status was $?."
    exit
fi

cd "${BACKUP_DIR}" || exit
