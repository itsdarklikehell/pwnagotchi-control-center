#!/bin/bash
MOUNT() {
    cd "${BACKUP_DIR}" || exit
    if [ -z "$SD_DEVICE" ]; then
        echo "$SD_DEVICE Variable is not set, make sure the corect value is set in .config/config..."
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

FILES=$(
    whiptail --title "Check list example" --checklist \
        "Choose what you want to Push" $LINES $COLUMNS $(($LINES - 8)) \
        "Handshakes" "Push handshakes from $BACKUP_DIR/Handshakes to $ROOT_MOUNT_DIR/$HANDSHAKE_DIR" ON \
        "Main Config" "Push main config.toml from $BACKUP_DIR/Configs to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml" ON \
        "Plugin Files" "Push plugin files from $BACKUP_DIR/Plugins to $CUSTOM_PLUGIN_DIR" ON \
        "Plugin Configs" "Push plugin configs from $BACKUP_DIR/Configs to $CUSTOM_PLUGIN_DIR" ON \
        "User Bin" "Push user bin from $BACKUP_DIR/Bin to /home/pi/bin" ON \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $FILES."
else
    echo "User selected Cancel."
    exit
fi

if [[ "$FILES" =~ "Handshakes" ]]; then
    echo "Pushing handshakes from $BACKUP_DIR/Handshakes to $ROOT_MOUNT_DIR/$HANDSHAKE_DIR."
    cp "$BACKUP_DIR/Handshakes/*" "$ROOT_MOUNT_DIR/$HANDSHAKE_DIR"
fi

if [[ "$FILES" =~ "Main Config" ]]; then
    echo "Pushing main config.toml from $BACKUP_DIR/Configs/config.toml to $ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml and $BOOT_MOUNT_DIR/boot/config.toml."
    cp "$BACKUP_DIR/Configs/config.toml" "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml"
    cp "$BACKUP_DIR/Configs/config.toml" "$BOOT_MOUNT_DIR/config.toml"
fi

if [[ "$FILES" =~ "Plugin Files" ]]; then
    echo "Pushing plugin files from $BACKUP_DIR/Plugins to $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR."
    cp "$BACKUP_DIR/Plugins/*" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR"
fi

if [[ "$FILES" =~ "Plugin Configs" ]]; then
    echo "Pushing plugin configs from $BACKUP_DIR/Plugins to $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR."
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.toml"
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.yml"
    cp "$BACKUP_DIR/Plugins" "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.yaml"
fi

if [[ "$FILES" =~ "User Bin" ]]; then
    echo "Pushing files from $BACKUP_DIR/Bin to $ROOT_MOUNT_DIR/home/pi/bin."
    cp "$BACKUP_DIR/Bin/*" "$ROOT_MOUNT_DIR/home/pi/bin"
fi
