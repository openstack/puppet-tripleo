# Copyright 2022 Red Hat, Inc.
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
# == Class: tripleo::profile::base::designate::coordination
#
# Designate Coordination profile for tripleo for setting coordination/redis
# related configuration.
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*designate_redis_password*]
#  (Optional) Password for the neutron redis user for the coordination url
#   Defaults to hiera('designate_redis_password', undef),
#
# [*redis_vip*]
#  (Optional) Redis ip address for the coordination url
#   Defaults to hiera('redis_vip', undef),
#
# [*enable_internal_tls*]
#   (Optional) Whether TLS in the internal network is enabled or not.
#   Defaults to hiera('enable_internal_tls', false)
#
class tripleo::profile::base::designate::coordination (
  $step                     = Integer(hiera('step')),
  $designate_redis_password = hiera('designate_redis_password', undef),
  $redis_vip                = hiera('redis_vip', undef),
  $enable_internal_tls      = hiera('enable_internal_tls', false),
) {
  if $step >= 4 {
    if $redis_vip {
      if $enable_internal_tls {
        $tls_query_param = '?ssl=true'
      } else {
        $tls_query_param = ''
      }
      class { 'designate::coordination':
        backend_url => join(['redis://:', $designate_redis_password, '@', normalize_ip_for_uri($redis_vip), ':6379/', $tls_query_param])
      }
    }
  }
}