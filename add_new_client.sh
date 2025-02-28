#!/usr/bin/env bash

# Copyright 2025 Genesis Corporation
#
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

# Function to display help message
show_help() {
    echo "Usage: $0 <service_address> <client_name>"
    echo "Generate client config."
}

# Check if the second argument is set
if [ -z "$2" ]; then
    show_help
    exit
fi

if [ -f "/etc/openvpn/easy-rsa/pki/issued/$2.crt" ]; then
    echo "Client file /etc/openvpn/easy-rsa/pki/issued/$2.crt already exists! Use other name"
    exit
fi

cd /etc/openvpn/easy-rsa || exit

export EASYRSA_BATCH=1
./easyrsa gen-req "$2" nopass
yes | ./easyrsa sign-req client "$2"

if [ ! -f "/etc/openvpn/easy-rsa/pki/issued/$2.crt" ]; then
    echo "Client file /etc/openvpn/easy-rsa/pki/issued/$2.crt not found!"
    exit
fi

CA=$(cat "/etc/openvpn/ca.crt")
KEY=$(cat "/etc/openvpn/easy-rsa/pki/private/$2.key")
CERT=$(cat "/etc/openvpn/easy-rsa/pki/issued/$2.crt")
TLS_AUTH=$(cat "/etc/openvpn/ta.key")

read -r -d '' TEMPLATE <<EOF
client

dev tun
proto udp

remote ${1} 1194
nobind

persist-key
persist-tun

verb 3

ca [inline]
<ca>
${CA}
</ca>
cert [inline]
<cert>
${CERT}
</cert>
key [inline]
<key>
${KEY}
</key>
tls-auth [inline] 1
<tls-auth>
${TLS_AUTH}
</tls-auth>
EOF

echo "$TEMPLATE" >"client_$2.conf"

echo "Client created, see file client_$2.conf"
