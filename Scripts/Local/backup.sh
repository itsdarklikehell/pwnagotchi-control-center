#!/bin/bash
BACKUP_DIR=$(whiptail --inputbox "What is the Backup dir?" $LINES $COLUMNS "${BACKUP_DIR}" --title "Backup dir." 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $BACKUP_DIR"
else
    echo "User selected Cancel."
fi

df -h >/tmp/dflist.txt

whiptail --title "Example Dialog" --textbox /tmp/dflist.txt $LINES $COLUMNS

cd "${BACKUP_DIR}" || exit

# if [ ! -f "${SD_DEVICE}" ]; then
#     echo "${SD_DEVICE} value is not set, make sure the corect value is set in .config/config..."
#     exit
# else
#     echo "SD_DEVICE value read from .config/config is ${SD_DEVICE}"
#     if [ ! -f pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip ]; then
#         echo "${DOWNLOAD_DIR}/${PWNAGOTCHI_VERSION} is not found, download it first and try again..."
#         exit
#     else
#         unzip -p "pwnagotchi-raspbian-lite-${PWNAGOTCHI_VERSION}.zip" | dd of="${SD_DEVICE}" bs=1M
#     fi
# fi
