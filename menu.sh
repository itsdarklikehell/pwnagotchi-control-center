#!/bin/bash

eval "resize"
#LINES="47"
#COLUMNS="190"
export COLUMNS LINES
# shellcheck source=/dev/null
source .config/config

option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Local stuff" "Scripts to run locally (ie. Flash or backup an sd card or edit and apply a config.toml to or from a mounted card)." \
        "Remote stuff" "Setup connection and run scripts on a remotely running pwnagotchi via ssh over usb/eth/bt-pan/wifi(ap)." \
        3>&1 1>&2 2>&3
)

if [ "$option" == "Local Stuff" ]; then
    ./Scripts/Local/menu.sh
fi

if [ "$option" == "Remote Stuff" ]; then
    ./Scripts/Remote/menu.sh
fi
