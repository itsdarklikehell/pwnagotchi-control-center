#!/bin/bash

UNMOUNT() {
    cd "${BACKUP_DIR}" || exit
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the corect value is set in .config/config..."
        exit
    else
        if (whiptail --title "Are you sure you want to unmount $SD_DEVICE?" --yesno "Unmount check." $LINES $COLUMNS); then
            echo "User selected Yes, exit status was $?."
            sudo umount "$SD_DEVICE"
        else
            echo "User selected No, exit status was $?."
            exit
        fi
    fi
}
FLASH() {
    cd "${BACKUP_DIR}" || exit
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the corect value is set in .config/config..."
        exit
    else
        echo "SD_DEVICE value read from .config/config is $SD_DEVICE"
        if [ ! -f "$BACKUP_NAME" ]; then
            echo "$BACKUP_NAME is not found."
            exit
        else
            dd if="$BACKUP_NAME" of="$SD_DEVICE" bs=1M status=process
            sync
        fi
    fi
}

BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR"
else
    echo "User selected Cancel."
    exit
fi

BACKUP_NAME=$(whiptail --inputbox "What is the Backup name?" $LINES $COLUMNS "$BACKUP_NAME" --title "Backup name." 3>&1 1>&2 2>&3)
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
SD_DEVICE=$(whiptail --inputbox "What is the Sd card to flash to?" $LINES $COLUMNS "${SD_DEVICE}" --title "Sd Card." 3>&1 1>&2 2>&3)
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
    FLASH
else
    echo "User selected No, exit status was $?."
    exit
fi
