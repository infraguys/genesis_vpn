#    Copyright 2025 Genesis Corporation.
#
#    All Rights Reserved.
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

import logging

from oslo_config import cfg

from genesis_vpn.common import constants
from genesis_vpn import version


GLOBAL_SERVICE_NAME = constants.GLOBAL_SERVICE_NAME


_CONFIG_NOT_FOUND_MESSAGE = (
    "Unable to find configuration file in the"
    " default search paths (~/.%(service_name)s/, ~/,"
    " /etc/%(service_name)s/, /etc/) and the '--config-file' option!"
    % {"service_name": GLOBAL_SERVICE_NAME}
)


def parse(args):
    cfg.CONF(
        args=args,
        project=GLOBAL_SERVICE_NAME,
        version="%s %s"
        % (
            GLOBAL_SERVICE_NAME.capitalize(),
            version.version_info,
        ),
    )
    if not cfg.CONF.config_file:
        logging.warning(_CONFIG_NOT_FOUND_MESSAGE)
    return cfg.CONF.config_file


service_config_opts = [
    cfg.StrOpt(
        "openvpn-client-configs-dir",
        help="Directory to store generated openvpn configs",
        required=True,
    ),
    cfg.StrOpt(
        "server-address",
        required=True,
        help="Address of openvpn server to connect to",
    ),
    cfg.IntOpt(
        "server-port",
        required=True,
        default=1194,
        help="Port of openvpn server to connect to",
    ),
    cfg.StrOpt(
        "server-protocol",
        required=True,
        choices=["udp", "tcp"],
        default="udp",
        help="Protocol to use for connecting to the openvpn server",
    ),
    cfg.StrOpt(
        "ca-cert-file",
        required=True,
        help="Path to the CA certificate file",
    ),
    cfg.StrOpt(
        "ca-key-file",
        required=True,
        help="Path to the CA key file",
    ),
    cfg.StrOpt(
        "tls-auth-file",
        required=True,
        help="Path to the TLS authentication file",
    ),
    cfg.StrOpt(
        "config-template",
        required=True,
        default="client_config.j2",
        help="Path to the configuration template file",
    ),
    cfg.IntOpt(
        "new-cert-validity-days",
        default=3650,
        help="Number of days for which the new certificate is valid",
    ),
    cfg.ListOpt(
        "server-reserved-cert-names",
        default=["server"],
        help="List of reserved common names for server certificates",
    ),
    cfg.ListOpt(
        "server-subnets",
        required=True,
        help="List of subnets that the openvpn servers will use. "
        "Used for API info only.",
    ),
]


def register_service_config_opts():
    cfg.CONF.register_cli_opts(service_config_opts, constants.COMMON_DOMAIN)
