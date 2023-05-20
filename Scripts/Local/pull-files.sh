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
    whiptail --inputbox "What is the Backup dir to copy to?" $LINES $COLUMNS "$BACKUP_DIR" --title "Backup dir." \
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
    whiptail --inputbox "What is the Sd card to copy to?" $LINES $COLUMNS "${SD_DEVICE}" --title "Sd Card." \
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
        "Choose what you want to Pull" $LINES $COLUMNS $(($LINES - 8)) \
        "Handshakes" "Pull handshakes from $ROOT_MOUNT_DIR/$HANDSHAKE_DIR to $BACKUP_DIR/Handshakes" ON \
        "Main Config" "Pull main config.toml from /etc/pwnagotchi/config.toml to $BACKUP_DIR/Configs" ON \
        "Plugin Files" "Pull plugin files from $CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins" ON \
        "Plugin Configs" "Pull plugin configs from $CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Configs" ON \
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
    if [ ! -d "$BACKUP_DIR/Handshakes" ]; then
        mkdir -P "$BACKUP_DIR/Handshakes"
    fi
    echo "Pulling handshakes from $ROOT_MOUNT_DIR/$HANDSHAKE_DIR to $BACKUP_DIR/Handshakes"
    cp "$ROOT_MOUNT_DIR/$HANDSHAKE_DIR/*" "$BACKUP_DIR/Handshakes"
fi

if [[ "$FILES" =~ "Main Config" ]]; then
    if [ ! -d "$BACKUP_DIR/Configs" ]; then
        mkdir -P "$BACKUP_DIR/Configs"
    fi
    echo "Pulling main config.toml from /etc/pwnagotchi/config.toml to $BACKUP_DIR/Configs/config.toml and /boot/config.toml"
    cp "$ROOT_MOUNT_DIR/etc/pwnagotchi/config.toml" "$BACKUP_DIR/Configs/config.toml"
    cp "$BOOT_MOUNT_DIR/config.toml" "$BACKUP_DIR/Configs/config.toml"
fi

if [[ "$FILES" =~ "Plugin Files" ]]; then
    if [ ! -d "$BACKUP_DIR/Plugins" ]; then
        mkdir -P "$BACKUP_DIR/Plugins"
    fi
    echo "Pulling plugin files from $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins"
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*" "$BACKUP_DIR/Plugins"
fi

if [[ "$FILES" =~ "Plugin Configs" ]]; then
    if [ ! -d "$BACKUP_DIR/Plugins" ]; then
        mkdir -P "$BACKUP_DIR/Plugins"
    fi
    echo "Pulling plugin configs from $ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR to $BACKUP_DIR/Plugins"
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.toml" "$BACKUP_DIR/Plugins"
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.yml" "$BACKUP_DIR/Plugins"
    cp "$ROOT_MOUNT_DIR/$CUSTOM_PLUGIN_DIR/*.yaml" "$BACKUP_DIR/Plugins"
fi
