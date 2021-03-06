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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'login'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'common'))
require 'oneview-sdk'

Puppet::Type.type(:oneview_logical_enclosure).provide(:oneview_logical_enclosure) do
  mk_resource_methods

  def initialize(*args)
    super(*args)
    @client = OneviewSDK::Client.new(login)
    @resourcetype = OneviewSDK::LogicalEnclosure
    # Initializes the data so it is parsed only on exists and accessible throughout the methods
    # This is not set here due to the 'resources' variable not being accessible in initialize
    @data = {}
  end

  def self.instances
    @client = OneviewSDK::Client.new(login)
    matches = OneviewSDK::LogicalEnclosure.find_by(@client)
    matches.collect do |line|
      name = line['name']
      data = line.inspect
      new(name: name,
          ensure: :present,
          data: data)
    end
  end

  # Provider methods
  def exists?
    @data = data_parse
    empty_data_check
    !@resourcetype.find_by(@client, @data).empty?
  end

  def create
    return true if resource_update(@data, @resourcetype)
    @resourcetype.new(@client, @data).create
    @property_hash[:ensure] = :present
    @property_hash[:data] = @data
    true
  end

  def destroy
    get_single_resource_instance.remove
    @property_hash.clear
    true
  end

  def found
    find_resources
  end

  def get_script
    Puppet.notice "\n\n-- Start of the configuration script :"
    pretty get_single_resource_instance.get_script
    Puppet.notice "\n\n-- End of the configuration script."
    true
  end

  def set_script
    script = @data.delete('script')
    raise 'The "script" field is required inside data in order to use this ensurable' unless script
    get_single_resource_instance.set_script(script)
    true
  end

  def updated_from_group
    get_single_resource_instance.update_from_group
  end

  def dumped
    dump = @data.delete('dump')
    raise 'The "dump" field is required inside data in order to use this ensurable' unless dump
    get_single_resource_instance.support_dump(dump)
  end
end
