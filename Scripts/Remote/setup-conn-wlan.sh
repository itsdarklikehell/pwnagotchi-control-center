#!/bin/bash
set -e

# Validate interface exists
validate_iface() {
    local iface="$1"
    if [ -z "$iface" ] || [ ! -d "/sys/class/net/$iface" ]; then
        whiptail --msgbox "Interface '$iface' does not exist. Available interfaces: $(ls /sys/class/net/ | tr '\n' ' ')" 10 60
        return 1
    fi
    return 0
}

WLAN_IFACE=$(whiptail --inputbox "What is the WLAN Interface name?" $LINES $COLUMNS "$WLAN_IFACE" --title "Interface name" 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "User selected Ok and entered $WLAN_IFACE"
else
    echo "User selected Cancel."
    exit 0
fi

validate_iface "$WLAN_IFACE" || exit 1

if [ "$(cat /sys/class/net/"$WLAN_IFACE"/operstate)" == "up" ]; then
    UPSTREAM_IFACE=$(whiptail --inputbox "What is the Upstream Interface name?" $LINES $COLUMNS "$UPSTREAM_IFACE" --title "Interface name" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        echo "User selected Ok and entered $UPSTREAM_IFACE"
    else
        echo "User selected Cancel."
        exit 0
    fi

    validate_iface "$UPSTREAM_IFACE" || exit 1

    # name of the ethernet gadget interface on the host
    WLAN_IFACE=${1:-$WLAN_IFACE}
    WLAN_IFACE_IP="10.0.0.1"
    WLAN_IFACE_NET="10.0.0.0/24"
    # host interface to use for upstream connection
    UPSTREAM_IFACE=${2:-$UPSTREAM_IFACE}

    sudo ip addr add "$WLAN_IFACE_IP/24" dev "$WLAN_IFACE"
    sudo ip link set "$WLAN_IFACE" up

    # Use iptables-restore for safer rule management
    sudo iptables -A FORWARD -o "$UPSTREAM_IFACE" -i "$WLAN_IFACE" -s "$WLAN_IFACE_NET" -m conntrack --ctstate NEW -j ACCEPT
    sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    # Only flush rules for this specific chain, not all NAT rules
    sudo iptables -t nat -D POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE 2>/dev/null || true
    sudo iptables -t nat -A POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE

    if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
        echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
    fi

    ssh "pi@10.0.0.2" "ping 1.1.1.1"
    export CURR_CONN="WLAN"
else
    echo "$WLAN_IFACE seems to be: $(cat "/sys/class/net/$WLAN_IFACE/operstate")"
fi
