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

provider_class = Puppet::Type.type(:oneview_firmware_driver).provider(:oneview_firmware_driver)

describe provider_class, unit: true do
  include_context 'shared context'

  let(:resource) do
    Puppet::Type.type(:oneview_firmware_driver).new(
      name: 'firmware_driver',
      ensure: 'found',
      data:
          {
            'name' => 'FirmwareDriver1_Example'
          }
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  context 'given the minimum parameters' do
    it 'should be an instance of the provider oneview_firmware_driver' do
      expect(provider).to be_an_instance_of Puppet::Type.type(:oneview_firmware_driver).provider(:oneview_firmware_driver)
    end

    it 'should raise error when Firmware Driver is not found' do
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, {}).and_return([])
      expect { provider.found }.to raise_error(/No FirmwareDriver with the specified data were found on the Oneview Appliance/)
    end
  end

  context 'given the create parameters' do
    let(:resource) do
      Puppet::Type.type(:oneview_firmware_driver).new(
        name: 'firmware_driver',
        ensure: 'present',
        data:
            {
              'customBaselineName' => 'FirmwareDriver1_Example',
              'baselineUri'        => '/rest/fake',
              'hotfixUris'         => ['/rest/fake']
            }
      )
    end
    before(:each) do
      test = OneviewSDK::FirmwareDriver.new(@client, resource['data'])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, 'name' => resource['data']['customBaselineName'])
        .and_return([test])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, name: resource['data']['baselineUri']).and_return([test])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, name: resource['data']['hotfixUris'][0]).and_return([test])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, name: resource['data']).and_return([])
      allow(OneviewSDK::FirmwareDriver).to receive(:get_all).with(anything).and_return([test])
      provider.exists?
    end

    it 'should be able to run through self.instances' do
      expect(instance).to be
    end

    it 'should create/add the Firmware Driver' do
      data = { 'uri' => '/rest/firmware-drivers/fake', 'baselineUri' => '/rest/fake',
               'hotfixUris' => ['/rest/fake'], 'customBaselineName' => 'FirmwareDriver1_Example' }
      resource['data']['uri'] = '/rest/firmware-drivers/fake'
      test = OneviewSDK::FirmwareDriver.new(@client, resource['data'])
      allow_any_instance_of(OneviewSDK::Client).to receive(:response_handler).and_return(test)
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_post)
        .with('/rest/firmware-drivers', { 'body' => data }, test.api_version).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.create).to be
    end

    it 'should delete the Firmware Driver' do
      resource['data']['uri'] = '/rest/firmware-drivers/fake'
      test = OneviewSDK::FirmwareDriver.new(@client, resource['data'])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, resource['data']).and_return([test])
      expect_any_instance_of(OneviewSDK::Client).to receive(:rest_delete).and_return(FakeResponse.new('uri' => '/rest/fake'))
      expect(provider.destroy).to be
    end

    it 'should be able to work specifying a name instead of an uri' do
      resource['data']['baselineUri'] = 'Test'
      test = OneviewSDK::FirmwareDriver.new(@client, resource['data'])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, name: resource['data']['baselineUri']).and_return([test])
      allow(OneviewSDK::FirmwareDriver).to receive(:find_by).with(anything, resource['data']).and_return([test])
      expect(provider.exists?).to be
    end
  end
end
