#
# Copyright (c) 2020 Seagate Technology LLC and/or its Affiliates
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# For any questions about this software or licensing,
# please email opensource@seagate.com or cortx-questions@seagate.com.
#

Delete old machine_id:
  file.absent:
    - names:
      - /etc/machine-id
      - /var/lib/dbus/machine-id

Refresh machine_id on {{ grains['id'] }}:
  cmd.run:
    - name: dbus-uuidgen --ensure=/etc/machine-id

Ensure_dbus_uuid_generation:
  cmd.run:
    - name: dbus-uuidgen --ensure

Check_network_service:
  cmd.run:
    - name: systemctl status network

Sync grains data after refresh machine_id:
  module.run:
    - saltutil.refresh_grains: []

