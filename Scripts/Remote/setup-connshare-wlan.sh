#!/bin/bash
set -e
WLAN_IFACE=$(whiptail --inputbox "What is the WLAN Interface name?" $LINES $COLUMNS "${WLAN_IFACE}" --title "Interface name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $WLAN_IFACE"
    #WLAN_IFACE="1:-${WLAN_IFACE}"
else
    echo "User selected Cancel."
fi

UPSTREAM_IFACE=$(whiptail --inputbox "What is the Upstream Interface name?" $LINES $COLUMNS "${UPSTREAM_IFACE}" --title "Interface name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $UPSTREAM_IFACE"
    #UPSTREAM_IFACE="2:-${UPSTREAM_IFACE}"
else
    echo "User selected Cancel."
fi

echo "(Exit status was $exitstatus)"
# name of the ethernet gadget interface on the host
WLAN_IFACE=${1:-$WLAN_IFACE}
WLAN_IFACE_IP="10.0.0.1"
WLAN_IFACE_NET="10.0.0.0/24"
# host interface to use for upstream connection
UPSTREAM_IFACE=${2:-$UPSTREAM_IFACE}

sudo ip addr add "$WLAN_IFACE_IP/24" dev "$WLAN_IFACE"
sudo ip link set "$WLAN_IFACE" up

sudo iptables -A FORWARD -o "$UPSTREAM_IFACE" -i "$WLAN_IFACE" -s "$WLAN_IFACE_NET" -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE

if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
    echo 1 | sudo tee -a /proc/sys/net/ipv4/ip_forward
fi

ssh "pi@10.0.0.2" "ping 1.1.1.1"
ssh "pi@10.0.0.2"
