#!/usr/bin/env bash

set -eu
set -x
set -o pipefail

IPprefix_by_netmask () {
   c=0 x=0$( printf '%o' ${1//./ } )
   while [ $x -gt 0 ]; do
       let c+=$((x%2)) 'x>>=1'
   done
   echo /$c ; }

SUBNET_PREFIX=$(IPprefix_by_netmask $ifconfig_netmask)
OVPN_SUBNET="$ifconfig_local$SUBNET_PREFIX"

# Get interface with default gateway, assume that we should route all incoming
#  traffic via this interface.
IF_NAME=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")


# set routes if not exist
rule="POSTROUTING -t nat -s $OVPN_SUBNET -o $IF_NAME -j MASQUERADE"
eval "iptables -C $rule >/dev/null 2>&1" || eval "iptables -I $rule"
