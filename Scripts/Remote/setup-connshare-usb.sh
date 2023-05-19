#!/bin/bash
set -e

# name of the ethernet gadget interface on the host
USB_IFACE=${1:-usb0}
USB_IFACE_IP="10.0.0.1"
USB_IFACE_NET="10.0.0.0/24"
# host interface to use for upstream connection
UPSTREAM_IFACE=${2:-enp2s0}

sudo ip addr add "$USB_IFACE_IP/24" dev "$USB_IFACE"
sudo ip link set "$USB_IFACE" up

sudo iptables -A FORWARD -o "$UPSTREAM_IFACE" -i "$USB_IFACE" -s "$USB_IFACE_NET" -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -F POSTROUTING
sudo iptables -t nat -A POSTROUTING -o "$UPSTREAM_IFACE" -j MASQUERADE

if [ "$(cat /proc/sys/net/ipv4/ip_forward)" != "1" ]; then
    echo 1 | sudo tee -a /proc/sys/net/ipv4/ip_forward
fi
