################################################################################
# (C) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

################################################################################
# (C) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

require 'spec_helper'
require_relative '../../support/fake_response'
require_relative '../../shared_context'

provider_class = Puppet::Type.type(:oneview_enclosure).provider(:oneview_enclosure)
resourcetype = OneviewSDK::Enclosure

describe provider_class, unit: true do
  include_context 'shared context'

  context 'given the min parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_enclosure).new(
        name: 'Enclosure',
        ensure: 'present',
        data:
            {
              'name' => 'Puppet_Test_Enclosure',
              'hostname' => '172.18.1.13',
              'username' => 'dcs',
              'password' => 'dcs',
              'enclosureGroupUri' => '/rest/',
              'licensingIntent' => 'OneView',
              'refreshState' => 'RefreshPending',
              'utilization_parameters' =>
              {
                'view' => 'day'
              }
            }
      )
    end

    let(:provider) { resource.provider }

    let(:instance) { provider.class.instances.first }

    before(:each) do
      test = resourcetype.new(@client, resource['data'])
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      provider.exists?
    end

    it 'should be an instance of the provider Ruby' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_enclosure).provider(:oneview_enclosure)
    end

    it 'should be able to find the resource' do
      expect(provider.found).to be
    end

    it 'should be able to get the environmental configuration' do
      allow_any_instance_of(resourcetype).to receive(:environmental_configuration).and_return('Test')
      expect(provider.get_environmental_configuration).to be
    end

    it 'should be able to set the configuration' do
      allow_any_instance_of(resourcetype).to receive(:configuration).and_return('Test')
      expect(provider.set_configuration).to be
    end

    it 'should be able to set the refresh state' do
      allow_any_instance_of(resourcetype).to receive(:set_refresh_state).and_return('Test')
      expect(provider.set_refresh_state).to be
    end

    it 'should be able to set the refresh state' do
      allow_any_instance_of(resourcetype).to receive(:utilization).with(resource['data']['utilization_parameters']).and_return('Test')
      expect(provider.get_utilization).to be
    end

    it 'should be able to set the refresh state' do
      allow_any_instance_of(resourcetype).to receive(:script).and_return('Test')
      expect(provider.get_script).to be
    end

    it 'should be able to set the refresh state' do
      expect { provider.get_single_sign_on }.to raise_error(RuntimeError)
    end

    it 'deletes the resource' do
      resource['data']['uri'] = '/rest/fake'
      test = resourcetype.new(@client, resource['data'])
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      allow(resourcetype).to receive(:find_by).with(anything, 'name' => resource['data']['name']).and_return([test])
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_delete).and_return(FakeResponse.new('uri' => '/rest/fake'))
      provider.exists?
      expect(provider.destroy).to be
    end
  end
end