# Copyright 2016 Red Hat, Inc.
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
# == Class: tripleo::profile::base::nova::compute_libvirt_shared
#
# Libvirt profile for tripleo. It will deploy Libvirt service and configure it.
#
# === Parameters
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*rbd_ephemeral_storage*]
#   (Optional) Use Ceph as ephmeral disk backend.
#   Defaults to hiera('nova::compute::rbd::ephemeral_storage', false)
#
# [*rbd_persistent_storage*]
#   (Optional) Use Ceph as volume backend.
#   Defaults to hiera('rbd_persistent_storage', false)
#
# [*rbd_disk_cachemodes*]
#   (Optional) Cache mode of rbd volumes.
#   Defaults to hiera('rbd_disk_cachemodes', ['network=writeback'])
#
class tripleo::profile::base::nova::compute_libvirt_shared (
  $step                   = Integer(hiera('step')),
  $rbd_ephemeral_storage  = hiera('nova::compute::rbd::ephemeral_storage', false),
  $rbd_persistent_storage = hiera('rbd_persistent_storage', false),
  $rbd_disk_cachemodes    = hiera('rbd_disk_cachemodes', ['network=writeback']),
) {
  if $step >= 4 {
    # Ceph + Libvirt
    if $rbd_ephemeral_storage or $rbd_persistent_storage {
      include nova::compute::rbd
    }

    if $rbd_ephemeral_storage {
      class { 'nova::compute::libvirt':
        disk_cachemodes => $rbd_disk_cachemodes,
        hw_disk_discard => 'unmap',
      }
    } else {
      include nova::compute::libvirt
    }
  }
}
