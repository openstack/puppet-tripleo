#
# Copyright (C) 2016 Red Hat, Inc.
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

describe 'tripleo::profile::base::aodh::api' do
  shared_examples_for 'tripleo::profile::base::aodh::api' do
    let(:pre_condition) do
      "class { '::tripleo::profile::base::aodh': step => #{params[:step]}, rabbit_hosts => ['127.0.0.1'] }"
    end

    context 'with step less than 4' do
      let(:params) { { :step => 3 } }

      it 'should do nothing' do
        is_expected.to contain_class('tripleo::profile::base::aodh::api')
        is_expected.to contain_class('tripleo::profile::base::aodh')
        is_expected.to_not contain_class('aodh::api')
        is_expected.to_not contain_class('aodh::wsgi::apache')
        is_expected.to_not contain_aodh_config('api/enable_combination_alarms')
      end
    end

    context 'with step 4' do
      let(:params) { {
        :step => 4,
      } }

      it 'should trigger complete configuration' do
        is_expected.to contain_class('aodh::api')
        is_expected.to contain_class('aodh::wsgi::apache')
        is_expected.to contain_aodh_config('api/enable_combination_alarms').with_value('false')
      end
    end

    context 'with step 4 and enable combo alarms' do
      let(:params) { {
        :step                      => 4,
        :enable_combination_alarms => true
      } }

      it 'should trigger complete configuration' do
        is_expected.to contain_class('aodh::api')
        is_expected.to contain_class('aodh::wsgi::apache')
        is_expected.to contain_aodh_config('api/enable_combination_alarms').with_value('true')
      end
    end

  end


  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ :hostname => 'node.example.com' })
      end

      it_behaves_like 'tripleo::profile::base::aodh::api'
    end
  end
end
