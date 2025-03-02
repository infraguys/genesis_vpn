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

set -eu
set -x
set -o pipefail

[[ "$EUID" == 0 ]] || exec sudo -s "$0" "$@"

SERVER_NAME=server

EL_PATH="/opt/genesis_vpn"

SYSTEMD_SERVICE_DIR=/etc/systemd/system/

# For silent non-interactive mode
export EASYRSA_BATCH=1

# Install packages
apt update
apt install openvpn openvpn-dco-dkms easy-rsa -y

# Prepare configs
make-cadir /etc/openvpn/easy-rsa

# Init server
cd /etc/openvpn/easy-rsa
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req $SERVER_NAME nopass
./easyrsa gen-dh

./easyrsa sign-req server $SERVER_NAME
openvpn --genkey --secret ta.key

cp ta.key pki/dh.pem pki/ca.crt "pki/issued/$SERVER_NAME.crt" "pki/private/$SERVER_NAME.key" /etc/openvpn/


cat $EL_PATH/etc/sysctl.conf >> /etc/sysctl.conf

cp "$EL_PATH/etc/openvpn/$SERVER_NAME.conf" "/etc/openvpn/"
cp "$EL_PATH/etc/openvpn/up.sh" "/etc/openvpn/"

systemctl enable "openvpn@$SERVER_NAME"


# To create client config, use add_new_client.sh
