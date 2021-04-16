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

describe 'tripleo::profile::base::barbican' do
  shared_examples_for 'tripleo::profile::base::barbican' do
    context 'with step less than 3' do
      let(:params) { { :step => 1 } }
      it 'should do nothing' do
        is_expected.to contain_class('tripleo::profile::base::barbican')
        is_expected.to_not contain_class('barbican')
        is_expected.to_not contain_class('barbican::config')
      end
    end

    context 'with step 3' do
      let(:params) { {
        :step           => 3,
      } }

      it 'should trigger complete configuration' do
        is_expected.to contain_class('barbican').with(
          :rabbit_hosts => params[:rabbit_hosts]
        )
        is_expected.to contain_class('barbican')
        is_expected.to contain_class('barbican::config')
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ :hostname => 'node.example.com' })
      end

      it_behaves_like 'tripleo::profile::base::barbican'
    end
  end
end
