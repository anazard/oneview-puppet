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

Puppet::Type.newtype(:oneview_enclosure_group) do
  desc "Oneview's Enclosure Group"

  # :nocov:
  ensurable do
    defaultvalues

    newvalue(:found) do
      provider.found
    end

    newvalue(:get_script) do
      provider.get_script
    end

    newvalue(:set_script) do
      provider.set_script
    end
  end
  # :nocov:

  newparam(:name, namevar: true) do
    desc 'Enclosure Group name'
  end

  newparam(:data) do
    desc 'Enclosure Group data hash containing all specifications for the resource'
    validate do |value|
      raise('Inserted value for data is not valid') unless value.class == Hash
    end
  end
end
