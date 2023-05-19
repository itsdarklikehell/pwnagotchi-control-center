#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Setup connection" "Download the latest pwnagotchi image." \
        "Flash Sd" "Flash the pwnagotchi image or zip file to an sd card." \
        "Backup Sd" "Backup an sd card to a flashable image or zip file." \
        "Modify Config" "Modify an config.toml." \
        3>&1 1>&2 2>&3
)
exitstatus=$?

if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered " $option
else
    echo "User selected Cancel."
fi

echo "(Exit status was $exitstatus)"

if [ "$option" == "Setup connection" ]; then
    echo "WIP."
fi
