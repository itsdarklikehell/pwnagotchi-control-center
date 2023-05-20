#!/bin/bash
if [ -z "$CURR_CONN" ]; then
    echo "CURR_CONN is not set, please run one of the Connection Setup scripts first."
else
    if [ "$CURR_CONN" == "BT" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "sudo reboot now"
    fi
    if [ "$CURR_CONN" == "USB" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "sudo reboot now"
    fi
    if [ "$CURR_CONN" == "ETH" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "sudo reboot now"
    fi
    if [ "$CURR_CONN" == "WLAN" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "sudo reboot now"
    fi
fi
