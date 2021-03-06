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
# == Class: tripleo::profile::base::designate::producer
#
# Designate Producer profile for tripleo
#
# === Parameters
#
# [*designate_redis_password*]
#  (Required) Password for the neutron redis user for the coordination url
#   Defaults to hiera('designate_redis_password', false),
#
# [*redis_vip*]
#  (Required) Redis ip address for the coordination url
#   Defaults to hiera('redis_vip', false),
#
# [*enable_internal_tls*]
#   (Optional) Whether TLS in the internal network is enabled or not.
#   Defaults to hiera('enable_internal_tls', false)
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::designate::producer (
  $designate_redis_password = hiera('designate_redis_password', false),
  $redis_vip                = hiera('redis_vip', false),
  $enable_internal_tls      = hiera('enable_internal_tls', false),
  $step                     = Integer(hiera('step')),
) {
  include tripleo::profile::base::designate

  if $enable_internal_tls {
    $tls_query_param = '?ssl=true'
  } else {
    $tls_query_param = ''
  }

  if $step >= 4 {
    if $redis_vip {
      class { 'designate::producer':
        backend_url => join(['redis://:', $designate_redis_password, '@', normalize_ip_for_uri($redis_vip), ':6379/', $tls_query_param])
      }
    } else {
      include designate::producer
    }
  }
}
