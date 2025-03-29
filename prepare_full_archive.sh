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
    echo "Usage: $0 <service_address> <client_name> <output_dir>"
    echo "Prepare dir with client config."
}

# Check if the second argument is set
if [ -z "$3" ]; then
    show_help
    exit
fi

if [ ! -f "/etc/openvpn/easy-rsa/pki/issued/$2.crt" ]; then
    echo "Client file /etc/openvpn/easy-rsa/pki/issued/$2.crt doesn't exists! Generate it first."
    exit
fi

CA="/etc/openvpn/ca.crt"
KEY="/etc/openvpn/easy-rsa/pki/private/$2.key"
CERT="/etc/openvpn/easy-rsa/pki/issued/$2.crt"
TLS_AUTH="/etc/openvpn/ta.key"

mkdir "$3"
cd "$3" || exit

read -r -d '' TEMPLATE <<EOF
client

dev tun
proto udp

remote ${1} 1194
nobind

persist-key
persist-tun

verb 3

ca ca.crt
cert cert.crt
key key.key
tls-auth ta.key 1
EOF

echo "$TEMPLATE" > "client.ovpn"

cp "$CA" ca.crt
cp "$KEY" key.key
cp "$CERT" cert.crt
cp "$TLS_AUTH" ta.key

tar -czvf "$2.tar.gz" ./*

echo "Dir prepared, see $3"

