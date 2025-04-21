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

import functools

import jinja2

from oslo_config import cfg

from genesis_vpn.common import constants


CONF = cfg.CONF


@functools.cache
def get_ca_cert():
    with open(CONF[constants.COMMON_DOMAIN].ca_cert_file, "r") as fp:
        return fp.read()


@functools.cache
def get_tls_auth():
    with open(CONF[constants.COMMON_DOMAIN].tls_auth_file, "r") as fp:
        return fp.read()


@functools.cache
def get_template():
    config_file = cfg.CONF.find_file(
        CONF[constants.COMMON_DOMAIN].config_template
    )

    with open(config_file) as f:
        return f.read()


def generate_ovpn_config(model):
    template = get_template()

    return jinja2.Template(template).render(
        server_address=CONF[constants.COMMON_DOMAIN].server_address,
        server_port=CONF[constants.COMMON_DOMAIN].server_port,
        server_protocol=CONF[constants.COMMON_DOMAIN].server_protocol,
        ca=get_ca_cert(),
        tls_auth=get_tls_auth(),
        **model
    )


def generate_ovpn_config_name(model):
    return ".".join((model.user_id, model.name, "ovpn"))
