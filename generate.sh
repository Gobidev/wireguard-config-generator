#!/bin/bash

SUBNET="192.168.42.0/24, fd86:ea04:1111::/64"
DNS="192.168.42.1, fd86:ea04:1111::1"

source SECRETS

# $1 = address
# $2 = allowed_ips = [all|vpn]

# generate client keys
privatekey="$(wg genkey)"
publickey="$(echo "$privatekey" | wg pubkey)"

[[ "$2" = "vpn" ]] && IPs="$SUBNET" || IPs="0.0.0.0/0, ::/0"

address=$(echo "$SUBNET" | sed -e "s/\/24/\/32/g" | sed -e "s/::\/64/::\/128/g" | sed -e "s/\.0\//\.$1\//g" | sed -e "s/::\//::$1\//g")

echo """
[Interface]
PrivateKey = $privatekey
Address = $address
DNS = $DNS
MTU = 1380

[Peer]
PublicKey = $ENDPOINT_PUBKEY
AllowedIPs = $IPs
Endpoint = $ENDPOINT
--------------------------------------------------
[Peer]
PublicKey = $publickey
AllowedIPs = $address
"""