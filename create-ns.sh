#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Variables:
NAMESPACE="netns1"

VETH_HOST="veth0"
VETH_HOST_IP="10.10.1.1/24"

VETH_NS="veth1"
VETH_NS_IP="10.10.2.1/24"

# create net namepsace
sudo ip netns add "$NAMESPACE"
sudo ip -n "$NAMESPACE" link set lo up

# create veth pair
sudo ip link add "$VETH_HOST" type veth peer name "$VETH_NS"
sudo ip link set "$VETH_NS" netns "$NAMESPACE"

sudo ip addr add "$VETH_HOST_IP" dev "$VETH_HOST"
sudo ip -n "$NAMESPACE" addr add "$VETH_NS_IP" dev "$VETH_NS"

sudo ip link set "$VETH_HOST" up
sudo ip -n "$NAMESPACE" link set "$VETH_NS" up

sudo ip route add "$VETH_NS_IP" dev "$VETH_HOST"
sudo ip -n "$NAMESPACE" route add default dev "$VETH_NS"

# enable NAT
sudo iptables -t nat -A POSTROUTING -s "10.10.2.0/24" ! -o "$VETH_HOST" -j MASQUERADE
