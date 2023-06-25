#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

set -o xtrace

# create net namepsace
sudo ip netns add "$NAMESPACE"
sudo ip -n "$NAMESPACE" link set lo up

sudo ip link add wg0 type wireguard
sudo ip link set wg0 netns $NAMESPACE

sudo ip -n $NAMESPACE addr add 10.2.0.2/32 dev wg0
sudo ip netns exec $NAMESPACE wg setconf wg0 /home/hatchan/wireguard/proton-vpn-wg0.conf
sudo ip -n $NAMESPACE link set wg0 up
sudo ip -n $NAMESPACE route add default dev wg0
