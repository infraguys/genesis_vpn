#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 <service_address> <client_name>"
    echo "Generate client config."
}

# Check if the first argument is set
if [ -z "$1" ]; then
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
