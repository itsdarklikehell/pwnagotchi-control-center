#!/bin/bash
BACKUP() {
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the corect value is set in .config/config..."
        exit
    else
        echo "Creating backup of $SD_DEVICE in $BACKUP_DIR/Images/$BACKUP_NAME.img"
        sudo dd if="$SD_DEVICE" of="$BACKUP_DIR/Images/$BACKUP_NAME.img" bs=1M status=progress
        sync
    fi
}
SHRINK() {
    mkdir ./Scripts/Local/PiShrink
    cd ./Scripts/Local/PiShrink || exit
    wget -C https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
    chmod +x pishrink.sh
    sudo cp pishrink.sh /usr/local/bin
    sudo pishrink.sh -ad "$BACKUP_DIR/Images/$BACKUP_NAME.img" "$BACKUP_DIR/Images/$BACKUP_NAME-shrunk.img" && rm "$BACKUP_DIR/Images/$BACKUP_NAME.img"
}
UNMOUNT() {
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

BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "$BACKUP_DIR/Images" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR"
else
    echo "User selected Cancel."
    exit
fi

BACKUP_NAME=$(whiptail --inputbox "What is the Backup name?" $LINES $COLUMNS "$BACKUP_NAME/Images" --title "Backup name." 3>&1 1>&2 2>&3)
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
SD_DEVICE=$(whiptail --inputbox "What is the Sd card?" $LINES $COLUMNS "$SD_DEVICE" --title "Sd Card." 3>&1 1>&2 2>&3)
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
