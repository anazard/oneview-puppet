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

provider_class = Puppet::Type.type(:oneview_power_device).provider(:oneview_power_device)
resourcetype = OneviewSDK::PowerDevice

describe provider_class, unit: true do
  include_context 'shared context'

  let(:resource) do
    Puppet::Type.type(:oneview_power_device).new(
      name: 'Power Device',
      ensure: 'discover',
      data:
          {
            'name' => '172.18.8.11, PDU 1'
          }
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  before(:each) do
    allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return(resource['data'])
    provider.exists?
  end

  context 'given the minimum parameters before server creation' do
    it 'should be an instance of the provider Ruby' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_power_device).provider(:oneview_power_device)
    end

    it 'should be able to find the resource' do
      test = resourcetype.new(@client, name: '172.18.8.11, PDU 1')
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      expect(provider.exists?).to be
      expect(provider.found).to be
    end

    it 'should not be able to find the resource' do
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([])
      expect(provider.exists?).not_to be
      expect { provider.found }.to raise_error(/No PowerDevice with the specified data were found on the Oneview Appliance/)
    end

    it 'should be able to discover the power device' do
      allow(resourcetype).to receive(:discover).with(anything, resource['data']).and_return('Test')
      expect(provider.discover).to be
    end

    it 'should get the UID state' do
      test = resourcetype.new(@client, name: '172.18.8.11, PDU 1')
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      provider.exists?
      allow_any_instance_of(resourcetype).to receive(:get_uid_state).and_return('Test')
      expect(provider.get_uid_state).to be
    end

    it 'should get the utilization without parameters' do
      test = resourcetype.new(@client, name: '172.18.8.11, PDU 1')
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      provider.exists?
      allow_any_instance_of(resourcetype).to receive(:utilization).with({}).and_return('Test')
      expect(provider.get_utilization).to be
    end
  end

  context 'given the set_refresh_state parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_power_device).new(
        name: 'Power Device',
        ensure: 'set_refresh_state',
        data:
            {
              'name' => '172.18.8.11, PDU 1',
              'refreshOptions' =>
              {
                'refreshState' => 'RefreshPending',
                'username'     => 'dcs',
                'password'     => 'dcs'
              }
            }
      )
    end

    let(:provider) { resource.provider }

    let(:instance) { provider.class.instances.first }

    it 'should refresh the power device' do
      test = resourcetype.new(@client, name: resource['data']['name'])
      allow(resourcetype).to receive(:find_by).and_return([test])
      expect(provider.exists?).to eq(true)
      expect_any_instance_of(resourcetype).to receive(:set_refresh_state).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.set_refresh_state).to be
    end
  end

  context 'given the minimum parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_power_device).new(
        name: 'Power Device',
        ensure: 'absent',
        data:
            {
              'name' => '172.18.8.11, PDU 1',
              'uidState' => 'On',
              'powerState' => 'On'
            }
      )
    end

    let(:provider) { resource.provider }

    let(:instance) { provider.class.instances.first }

    it 'should delete the resource' do
      resource['data']['uri'] = '/rest/fake/'
      test = resourcetype.new(@client, resource['data'])
      allow(resourcetype).to receive(:find_by).with(anything, resource['data']).and_return([test])
      provider.exists?
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_delete).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.destroy).to be
    end

    it 'should be able to create the resource' do
      body = { 'name' => '172.18.8.11, PDU 1', 'deviceType' => 'BranchCircuit', 'phaseType' => 'Unknown', 'powerConnections' => [] }
      test = resourcetype.new(@client, name: resource['data']['name'])
      allow(resourcetype).to receive(:find_by).with(anything, 'name' => resource['data']['name']).and_return([])
      provider.exists?
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_post)
        .with('/rest/power-devices', { 'body' => body }, test.api_version).and_return(FakeResponse.new('uri' => '/rest/fake'))
      allow_any_instance_of(OneviewSDK::Client).to receive(:response_handler).and_return(uri: '/rest/power-devices/fake')
      expect(provider.create).to be
    end

    it 'should set the uid state' do
      test = resourcetype.new(@client, name: resource['data']['name'])
      allow(resourcetype).to receive(:find_by).and_return([test])
      expect(provider.exists?).to eq(true)
      expect_any_instance_of(resourcetype).to receive(:set_uid_state).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.set_uid_state).to be
    end

    it 'should set the power state' do
      test = resourcetype.new(@client, name: resource['data']['name'])
      allow(resourcetype).to receive(:find_by).and_return([test])
      expect(provider.exists?).to eq(true)
      expect_any_instance_of(resourcetype).to receive(:set_power_state).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.set_power_state).to be
    end
  end
end
