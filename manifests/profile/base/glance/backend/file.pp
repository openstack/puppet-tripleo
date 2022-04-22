# Copyright 2020 Red Hat, Inc.
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
# == Class: tripleo::profile::base::glance::backend::file
#
# Glance API file backend configuration for tripleo
#
# === Parameters
#
# [*backend_names*]
#   Array of file store backend names.
#
# [*multistore_config*]
#   (Optional) Hash containing multistore data for configuring multiple backends.
#   Defaults to {}
#
# [*filesystem_store_datadir*]
#   (Optional) Location where dist images are stored when the backend type is file.
#   Defaults to lookup('glance::backend::file::filesystem_store_datadir', undef, undef, undef).
#
# [*filesystem_thin_provisioning*]
#   (Optional) Boolean describing if thin provisioning is enabled or not
#   Defaults to lookup('glance::backend::file::filesystem_thin_provisioning', undef, undef, undef).
#
# [*store_description*]
#   (Optional) Provides constructive information about the store backend to
#   end users.
#   Defaults to lookup('tripleo::profile::base::glance::api::glance_store_description', undef, undef, 'File store').
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to Integer(lookup('step'))
#
class tripleo::profile::base::glance::backend::file (
  $backend_names,
  $multistore_config            = {},
  $filesystem_store_datadir     = lookup('glance::backend::file::filesystem_store_datadir', undef, undef, undef),
  $filesystem_thin_provisioning = lookup('glance::backend::file::filesystem_thin_provisioning', undef, undef, undef),
  $store_description            = lookup('tripleo::profile::base::glance::api::glance_store_description', undef, undef, 'File store'),
  $step                         = Integer(lookup('step')),
) {

  if $backend_names.length() > 1 {
    fail('Multiple file backends are not supported.')
  }

  if $step >= 4 {
    $backend_name = $backend_names[0]

    $multistore_description = pick($multistore_config[$backend_name], {})['GlanceStoreDescription']
    $store_description_real = pick($multistore_description, $store_description)

    create_resources('glance::backend::multistore::file', { $backend_name => delete_undef_values({
      'filesystem_store_datadir'     => $filesystem_store_datadir,
      'filesystem_thin_provisioning' => $filesystem_thin_provisioning,
      'store_description'            => $store_description_real,
    })})
  }
}
