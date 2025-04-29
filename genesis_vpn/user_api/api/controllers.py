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

import urllib.parse

from gcl_iam import controllers as iam_controllers
from restalchemy.api import actions
from restalchemy.api import controllers as ra_controllers
from restalchemy.api import constants
from restalchemy.api import field_permissions as field_p
from restalchemy.api import packers
from restalchemy.api import resources

from genesis_vpn.common import ovpn_config
from genesis_vpn.dm import models
from genesis_vpn.user_api.api import versions


class RootController(ra_controllers.Controller):
    """Controller for / endpoint"""

    def filter(self, filters):
        return (versions.API_VERSION_1_0,)


class ApiEndpointController(ra_controllers.RoutesListController):
    """Controller for /v1/ endpoint"""

    __TARGET_PATH__ = "/v1/"


class CertificateController(
    iam_controllers.PolicyBasedWithoutProjectController,
    ra_controllers.BaseResourceControllerPaginated,
):
    __policy_service_name__ = "vpn"
    __policy_name__ = "certificates"

    __packer__ = packers.MultipartPacker

    __resource__ = resources.ResourceByRAModel(
        models.Certificate,
        convert_underscore=False,
        fields_permissions=field_p.FieldsPermissions(
            default=field_p.Permissions.RW,
            fields={
                "req": {constants.ALL: field_p.Permissions.HIDDEN},
                "key": {constants.ALL: field_p.Permissions.HIDDEN},
                "cert": {constants.ALL: field_p.Permissions.HIDDEN},
            },
        ),
    )

    @actions.get
    def get_ovpn_config(self, resource):
        self._enforce("*:read:ovpn_config")
        headers = {
            "Content-Type": constants.CONTENT_TYPE_OCTET_STREAM,
            "Content-Disposition": 'attachment; filename="%s"'
            % urllib.parse.quote(
                ovpn_config.generate_ovpn_config_name(resource)
            ),
        }

        return (
            ovpn_config.generate_ovpn_config(model=resource).encode("utf-8"),
            200,
            headers,
        )
