#!/bin/bash
PLUGINNAME=$(whiptail --inputbox "What is the plugin name?" $LINES $COLUMNS "${PLUGINNAME}" --title "Plugin name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BT_IFACE"
else
    echo "User selected Cancel."
fi

if [ -z "$CURR_CONN" ]; then
    echo "CURR_CONN is not set, please run one of the Connection Setup scripts first."
else
    if [ "$CURR_CONN" == "BT" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "sudo pwnagotchi plugins install $PLUGINNAME"
    fi
    if [ "$CURR_CONN" == "USB" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "sudo pwnagotchi plugins install $PLUGINNAME"
    fi
    if [ "$CURR_CONN" == "ETH" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "sudo pwnagotchi plugins install $PLUGINNAME"
    fi
    if [ "$CURR_CONN" == "WLAN" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "sudo pwnagotchi plugins install $PLUGINNAME"
    fi
fi
