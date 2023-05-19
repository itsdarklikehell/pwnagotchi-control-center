#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Setup usb-ethernet connection" "Setup a usb-ethernet connection share with a pwnagotchi." \
        "Setup bluetooth-pan connection" "Setup a bluetooth-pan connection share with a pwnagotchi." \
        "Setup ethernet connection" "Setup a ethernet connection share with a pwnagotchi." \
        "Setup wlan-ap connection" "Setup a wlan-ap connection share with a pwnagotchi." \
        "Modify Config" "Modify a remote config.toml." \
        "install a plugin" "Modify a remote config.toml." \
        "Reboot pwnagotchi" "Reboot a remote pwnagotchi." \
        3>&1 1>&2 2>&3
)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $option"
else
    echo "User selected Cancel."
    exit
fi

if [ "$option" == "Setup usb-ethernet connection" ]; then
    export CONNECTION="USB"
    ./Scripts/Remote/setup-connshare-usb.sh
fi

if [ "$option" == "Setup bluetooth-pan connection" ]; then
    export CONNECTION="BT"
    ./Scripts/Remote/setup-connshare-bt.sh
fi

if [ "$option" == "Setup ethernet connection" ]; then
    export CONNECTION="ETH"
    ./Scripts/Remote/setup-connshare-eth.sh
fi

if [ "$option" == "Setup wlan-ap connection" ]; then
    export CONNECTION="ETH"
    ./Scripts/Remote/setup-connshare-wlan.sh
fi

if [ "$option" == "Reboot pwnagotchi" ]; then
    if [ "$CONNECTION" == "BT" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "sudo reboot now"
    fi
    if [ "$CONNECTION" == "USB" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "sudo reboot now"
    fi
    if [ "$CONNECTION" == "ETH" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "sudo reboot now"
    fi
fi
