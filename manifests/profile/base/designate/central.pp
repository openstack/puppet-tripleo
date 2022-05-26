# Copyright 2017 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::designate::central
#
# Designate Central profile for tripleo
#
# === Parameters
#
# [*bootstrap_node*]
#   (Optional) The hostname of the node responsible for bootstrapping tasks
#   Defaults to lookup('designate_central_short_bootstrap_node_name', undef, undef, undef)
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to Integer(lookup('step'))
#
# DEPRECATED PARAMETERS
#
# [*pools_file_content*]
#   (Optional) The content of /etc/designate/pools.yaml
#   Defaults to the content of templates/designate/pools.yaml.erb
#
class tripleo::profile::base::designate::central (
  $bootstrap_node = lookup('designate_central_short_bootstrap_node_name', undef, undef, undef),
  $step           = Integer(lookup('step')),
  # DEPRECATED PARAMETERS
  $pools_file_content = undef,
) {
  if $bootstrap_node and $::hostname == downcase($bootstrap_node) {
    $sync_db = true
  } else {
    $sync_db = false
  }

  if $pools_file_content {
    warning('pool file content is no longer manually configurable')
  }

  include tripleo::profile::base::designate
  include tripleo::profile::base::designate::coordination

  if ($step >= 4 or ($step >= 3 and $sync_db)) {
    class { 'designate::db':
      sync_db => $sync_db,
    }
    include designate::central
    include designate::quota
    include designate::network_api::neutron
  }
}
