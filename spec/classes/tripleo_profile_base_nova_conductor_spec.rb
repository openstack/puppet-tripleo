#
# Copyright (C) 2017 Red Hat, Inc.
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

require 'spec_helper'

describe 'tripleo::profile::base::nova::conductor' do
  shared_examples_for 'tripleo::profile::base::nova::conductor' do
    let(:pre_condition) do
      <<-eos
      class { 'tripleo::profile::base::nova':
        step => #{params[:step]},
        oslomsg_rpc_hosts => [ '127.0.0.1' ],
      }
eos
    end

    context 'with step less than 3' do
      let(:params) { { :step => 3, } }

      it {
        is_expected.to contain_class('tripleo::profile::base::nova::conductor')
        is_expected.to contain_class('tripleo::profile::base::nova')
        is_expected.to_not contain_class('nova::db::sync')
        is_expected.to_not contain_class('nova::conductor')
        is_expected.to_not contain_class('nova::network::neutron')
      }
    end

    context 'with step 3 on bootstap node' do
      let(:params) { {
        :step           => 3,
        :bootstrap_node => 'node.example.com',
      } }

      it {
        is_expected.to contain_class('tripleo::profile::base::nova::conductor')
        is_expected.to contain_class('tripleo::profile::base::nova')
        is_expected.to contain_class('nova::db::sync')
        is_expected.to_not contain_class('nova::conductor')
        is_expected.to_not contain_class('nova::network::neutron')
      }
    end

    context 'with step 3 not on bootstap node' do
      let(:params) { {
        :step           => 3,
        :bootstrap_node => 'other.example.com',
      } }

      it {
        is_expected.to contain_class('tripleo::profile::base::nova::conductor')
        is_expected.to contain_class('tripleo::profile::base::nova')
        is_expected.to_not contain_class('nova::db::sync')
        is_expected.to_not contain_class('nova::conductor')
        is_expected.to_not contain_class('nova::network::neutron')
      }
    end

    context 'with step 4 on bootstap node' do
      let(:params) { {
        :step           => 4,
        :bootstrap_node => 'node.example.com',
      } }

      it {
        is_expected.to contain_class('tripleo::profile::base::nova::conductor')
        is_expected.to contain_class('tripleo::profile::base::nova')
        is_expected.to contain_class('nova::db::sync')
        is_expected.to contain_class('nova::conductor')
        is_expected.to contain_class('nova::network::neutron')
      }
    end

    context 'with step 4 not on bootstap node' do
      let(:params) { {
        :step           => 4,
        :bootstrap_node => 'other.example.com',
      } }

      it {
        is_expected.to contain_class('tripleo::profile::base::nova::conductor')
        is_expected.to contain_class('tripleo::profile::base::nova')
        is_expected.to_not contain_class('nova::db::sync')
        is_expected.to contain_class('nova::conductor')
        is_expected.to contain_class('nova::network::neutron')
      }
    end
  end


  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ :hostname => 'node.example.com' })
      end

      it_behaves_like 'tripleo::profile::base::nova::conductor'
    end
  end
end
