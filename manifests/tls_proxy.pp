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
# == Class: tripleo::tls_proxy
#
# Sets up a TLS proxy using mod_proxy that redirects towards localhost.
#
# === Parameters
#
# [*ip*]
#   (Required) The IP address that the proxy will be listening on.
#
# [*port*]
#   (Required) The port that the proxy will be listening on.
#
# [*servername*]
#   (Required) The vhost servername that contains the FQDN to identify
#   the virtual host.
#
# [*tls_cert*]
#   (Required) The path to the TLS certificate that the proxy will be serving.
#
# [*tls_key*]
#   (Required) The path to the key used for the specified certificate.
#
# [*preserve_host*]
#   (Optional) Whether the Host header is preserved in proxied requests.
#   See the Apache ProxyPreserveHost directive docs.
#   Defaults to false
#
# [*proxy_pass_host*]
#   (Optional) The host to connect to.
#   Defaults to lookup('localhost_address', undef, undef, 'localhost')
#
define tripleo::tls_proxy(
  $ip,
  $port,
  $servername,
  $tls_cert,
  $tls_key,
  $preserve_host   = false,
  $proxy_pass_host = lookup('localhost_address', undef, undef, 'localhost')
) {
  include apache
  ::apache::vhost { "${title}-proxy":
    ensure              => 'present',
    docroot             => false,  # This is required by the manifest
    manage_docroot      => false,
    servername          => $servername,
    ip                  => $ip,
    # NOTE(tkajinam): apache::vhost::port no longer accepts a string value
    #                 since v8.0.0.
    port                => Integer($port),
    ssl                 => true,
    ssl_cert            => $tls_cert,
    ssl_key             => $tls_key,
    request_headers     => ['set X-Forwarded-Proto "https"'],
    proxy_preserve_host => $preserve_host,
    proxy_pass          => {
      path   => '/',
      url    => "http://${proxy_pass_host}:${port}/",
      params => {retry => '10'},
    }
  }
}
