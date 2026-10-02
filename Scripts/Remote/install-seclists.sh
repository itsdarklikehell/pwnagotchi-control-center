#!/bin/bash
INSTALL_DIR=$(whiptail --inputbox "What is the install directory?" $LINES $COLUMNS "${HOME}/SecLists" --title "Install directory" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $INSTALL_DIR"
else
    echo "User selected Cancel."
fi

if [ -z "$CURR_CONN" ]; then
    echo "CURR_CONN is not set, please run one of the Connection Setup scripts first."
else
    if [ "$CURR_CONN" == "BT" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "git clone https://github.com/danielmiessler/SecLists $INSTALL_DIR"
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_BTIP" "cd $INSTALL_DIR && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
    fi
    if [ "$CURR_CONN" == "USB" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "git clone https://github.com/danielmiessler/SecLists $INSTALL_DIR"
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_USBIP" "cd $INSTALL_DIR && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
    fi
    if [ "$CURR_CONN" == "ETH" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "git clone https://github.com/danielmiessler/SecLists $INSTALL_DIR"
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_ETHIP" "cd $INSTALL_DIR && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
    fi
    if [ "$CURR_CONN" == "WLAN" ]; then
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "git clone https://github.com/danielmiessler/SecLists $INSTALL_DIR"
        ssh "$PWNAGOTCHI_USERNAME"@"$PWNAGOTCHI_WLANIP" "cd $INSTALL_DIR && ln -s Discovery discovery && ln -s Usernames usernames && ln -s Passwords passwords && ln -s Fuzzing fuzzing && ln -s Miscellaneous misc"
    fi
fi
