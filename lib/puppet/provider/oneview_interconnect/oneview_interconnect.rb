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

Puppet::Type.type(:oneview_interconnect).provide(:oneview_interconnect) do
  mk_resource_methods

  def initialize(*args)
    super(*args)
    @client = OneviewSDK::Client.new(login)
    @resourcetype = OneviewSDK::Interconnect
    @data = {}
  end

  def exists?
    @data = data_parse
    empty_data_check([:found, :get_types])
    variable_assignments
    # Checks if there is a patch update to be performed
    get_single_resource_instance.patch(@patch['op'], @patch['path'], @patch['value']) if @patch
    !@resourcetype.find_by(@client, @data).empty?
  end

  def create
    raise('This resource relies on others to be created.')
  end

  def destroy
    raise('This resource relies on others to be destroyed.')
  end

  def found
    find_resources
  end

  def get_types
    Puppet.notice("\n\nInterconnect Types\n")
    if @data['name']
      pretty @resourcetype.get_type(@client, @data['name'])
    else
      pretty @resourcetype.get_types(@client)
    end
  end

  # it is possible to query by either portName, subportNumber or nothing (for all)
  def get_statistics
    Puppet.notice("\n\nInterconnect Statistics\n")
    if @statistics
      @statistics['portName'] = nil unless @statistics['portName']
      @statistics['subportNumber'] = nil unless @statistics['subportNumber']
      pretty get_single_resource_instance.statistics(@statistics['portName'], @statistics['subportNumber'])
    else
      get_single_resource_instance.statistics
    end
    true
  end

  def get_name_servers
    Puppet.notice("\n\nInterconnect Name Servers\n")
    pretty get_single_resource_instance.name_servers
    true
  end

  def update_ports
    Puppet.notice("\n\nUpdating ports...\n")
    interconnect = get_single_resource_instance
    raise('The port information needs to be specified for this action.') unless @ports
    @ports.each do |port|
      port_name = port.delete('portName')
      Puppet.notice("The port #{port_name} has been updated.") if interconnect.update_port(port_name, port)
    end
  end

  def reset_port_protection
    Puppet.notice("\n\nResetting Port Protection...\n")
    get_single_resource_instance.reset_port_protection
  end

  # Helpers

  def variable_assignments
    @patch = @data.delete('patch')
    @ports = @data.delete('ports')
    @statistics = @data.delete('statistics')
  end
end
