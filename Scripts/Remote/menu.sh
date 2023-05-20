#!/bin/bash
option=$(
    whiptail --title "Main Menu." --menu "Choose an option" $LINES $COLUMNS $(($LINES - 8)) \
        "Setup usb-ethernet connection" "Setup a usb-ethernet connection share with a pwnagotchi." \
        "Setup bluetooth-pan connection" "Setup a bluetooth-pan connection share with a pwnagotchi." \
        "Setup ethernet connection" "Setup a ethernet connection share with a pwnagotchi." \
        "Setup wlan-ap connection" "Setup a wlan-ap connection share with a pwnagotchi." \
        "Modify Pwnagotchi Config" "Modify a remote config.toml." \
        "Modify Plugin Config" "Modify a remote pluginname.toml." \
        "Install SecLists" "Install SecLists wordlists." \
        "Install Plugin" "Install a remote plugin." \
        "Enable Plugin" "Enable a remote plugin." \
        "Disable Plugin" "Disable a remote plugin." \
        "Update pwnagotchi" "Update the pwnagotchi." \
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
    ./Scripts/Remote/setup-conn-usb.sh
fi

if [ "$option" == "Setup bluetooth-pan connection" ]; then
    ./Scripts/Remote/setup-conn-bt.sh
fi

if [ "$option" == "Setup ethernet connection" ]; then
    ./Scripts/Remote/setup-conn-eth.sh
fi

if [ "$option" == "Setup wlan-ap connection" ]; then
    ./Scripts/Remote/setup-conn-wlan.sh
fi

if [ "$option" == "Reboot pwnagotchi" ]; then
    ./Scripts/Remote/reboot.sh
fi

if [ "$option" == "Modify Pwnagotchi Config" ]; then
    ./Scripts/Remote/mod-pwnagotchi-conf.sh
fi

if [ "$option" == "Modify Plugin Config" ]; then
    ./Scripts/Remote/mod-plugin-conf.sh
fi

if [ "$option" == "Install SecLists" ]; then
    ./Scripts/Remote/install-seclist.sh
fi

if [ "$option" == "Install Plugin" ]; then
    ./Scripts/Remote/plugin-install.sh
fi

if [ "$option" == "Enable Plugin" ]; then
    ./Scripts/Remote/plugin-enable.sh
fi

if [ "$option" == "Disable Plugin Config" ]; then
    ./Scripts/Remote/plugin-disable.sh
fi
