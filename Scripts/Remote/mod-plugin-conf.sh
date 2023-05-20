#!/bin/bash
if [ -z "$CURR_CONN" ]; then
    echo "CURR_CONN is not set, please run one of the Connection Setup scripts first."
else
    if [ "$CURR_CONN" == "BT" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "sudo nano $CUSTOM_PLUGIN_DIR/pluginname.toml"
    fi
    if [ "$CURR_CONN" == "USB" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "sudo nano $CUSTOM_PLUGIN_DIR/pluginname.toml"
    fi
    if [ "$CURR_CONN" == "ETH" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "sudo nano $CUSTOM_PLUGIN_DIR/pluginname.toml"
    fi
    if [ "$CURR_CONN" == "WLAN" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "sudo nano $CUSTOM_PLUGIN_DIR/pluginname.toml"
    fi
fi
