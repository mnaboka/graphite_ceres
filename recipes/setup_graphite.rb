# Maksym Naboka 2014
# Cookbook Name:: graphite_ceres
# Recipe:: setup_graphite
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

carbon_daemons = "#{node['graphite']['base_dir']}/conf/carbon-daemons"

node['graphite']['daemons'].each do |daemon|
  # Process config dir
  directory "#{carbon_daemons}/#{daemon['name']}" do
    owner "#{node['graphite']['group_account']}"
    group "#{node['graphite']['group_account']}"
    mode '0644'
    action :create
  end

  daemon.each do |key, value|
    Chef::Log.info("MMM" + key)
    next if key == 'name'

    template "#{carbon_daemons}/#{daemon['name']}/#{key}.conf" do
      source "#{key}.conf.erb"
      owner "#{node['graphite']['group_account']}"
      group "#{node['graphite']['group_account']}"
      mode '0644'
      variables(
        :daemon => daemon
      )
    end
  end

end

