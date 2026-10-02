#!/bin/bash
# Modify config.toml on the boot partition of an SD card
MOUNT() {
    cd "${BACKUP_DIR}" || exit
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the correct value is set in .config/config..."
        exit
    else
        if (whiptail --title "Are you sure you want to mount $SD_DEVICE?" --yesno "Mount check." $LINES $COLUMNS); then
            echo "User selected Yes, exit status was $?."
            sudo mount -a
        else
            echo "User selected No, exit status was $?."
            exit
        fi
    fi
}

BACKUP_DIR=$(
    whiptail --inputbox "What is the Backup dir to copy to?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR."
else
    echo "User selected Cancel."
    exit
fi

sudo apt install hwinfo
grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short) >/tmp/usblist.txt
whiptail --title "Usb List." --textbox /tmp/usblist.txt $LINES $COLUMNS

SD_DEVICE=$(
    whiptail --inputbox "What is the Sd card to copy to?" $LINES $COLUMNS "$SD_DEVICE" --title "Sd Card." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $SD_DEVICE."
else
    echo "User selected Cancel."
    exit
fi

MOUNT

if [ -f "$BOOT_MOUNT_DIR/config.toml" ]; then
    cp "$BOOT_MOUNT_DIR/config.toml" "$BACKUP_DIR/Configs/config.toml"
    nano "$BACKUP_DIR/Configs/config.toml"
    cp "$BACKUP_DIR/Configs/config.toml" "$BOOT_MOUNT_DIR/config.toml"
    echo "Config updated on $BOOT_MOUNT_DIR/config.toml"
else
    echo "No config.toml found on $BOOT_MOUNT_DIR"
fi
