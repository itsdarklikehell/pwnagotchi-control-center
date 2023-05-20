#!/bin/bash
MOUNT() {
    cd "${BACKUP_DIR}" || exit
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the corect value is set in .config/config..."
        exit
    else
        if (whiptail --title "Are you sure you want to mount $SD_DEVICE?" --yesno "Unmount check." $LINES $COLUMNS); then
            echo "User selected Yes, exit status was $?."
            sudo mount -a
        else
            echo "User selected No, exit status was $?."
            exit
        fi
    fi
}

BACKUP_DIR=$(
    whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR"
else
    echo "User selected Cancel."
    exit
fi

sudo apt install hwinfo
grep -Ff <(hwinfo --disk --short) <(hwinfo --usb --short) >/tmp/usblist.txt
whiptail --title "Usb List." --textbox /tmp/usblist.txt $LINES $COLUMNS

SD_DEVICE=$(
    whiptail --inputbox "What is the Sd card to flash to?" $LINES $COLUMNS "${SD_DEVICE}" --title "Sd Card." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $SD_DEVICE"
else
    echo "User selected Cancel."
    exit
fi

FILES=$(
    whiptail --title "Check list example" --checklist \
        "Choose user's permissions" $LINES $COLUMNS $(($LINES - 8)) \
        "Handshakes" "Allow connections to other hosts" ON \
        "Main Config" "Allow connections from other hosts" ON \
        "Plugin File" "Allow mounting of local devices" ON \
        "Plugin Config" "Allow mounting of remote devices" ON \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $FILES"
else
    echo "User selected Cancel."
    exit
fi

if [[ "$FILES" =~ "Handshakes" ]]; then
    echo "Extracting handshakes from $HANDSHAKE_DIR to $BACKUP_DIR"
fi

# case $FILES in
# *"Handshakes"*)
#     echo "Extracting handshakes from $HANDSHAKE_DIR to $BACKUP_DIR"
#     ;;
# esac
