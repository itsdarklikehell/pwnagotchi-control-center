#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Download Image" "Download the pwnagotchi image." \
        "Flash Sd" "Flash or restore a pwnagotchi image or zip file to an Sd Card." \
        "Backup Sd" "Backup an sd card to a flashable image or zip file." \
        "Modify Config" "Modify an config.toml and store it on te /boot partiton of the Sd Card." \
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
    ./Scripts/Local/download.sh
fi

if [ "$option" == "Flash Sd" ]; then
    ./Scripts/Local/flash.sh
fi

if [ "$option" == "Backup Sd" ]; then
    ./Scripts/Local/backup.sh
fi

if [ "$option" == "Modify Config" ]; then
    ./Scripts/Local/modconf.sh
fi
