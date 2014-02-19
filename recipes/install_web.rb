# Maksym Naboka 2014
# Cookbook Name:: graphite_ceres
# Recipe:: install_web
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
include_recipe 'git'

web = 'web'
git "#{Chef::Config[:file_cache_path]}/#{web}" do
  repository node['graphite']['web']['git']
  reference node['graphite']['web']['branch']
  action :checkout
  notifies :run, "execute[remove_cairo_dep]"
end

execute "remove_cairo_dep" do
  command "sed -i '/cairo/d' #{web}/requirements.txt"
  cwd Chef::Config[:file_cache_path]
  action :nothing
  notifies :run, "execute[install_web_dependencies]"
end

execute "install_web_dependencies" do
  command "pip install -r #{web}/requirements.txt"
  cwd Chef::Config[:file_cache_path]
  action :nothing
end

execute "python_install_web" do
  command "python setup.py install --prefix=#{node['graphite']['base_dir']}"
  cwd Chef::Config[:file_cache_path] + "/#{web}"
  not_if { ::File.exists?("#{node['graphite']['base_dir']}/webapp") }
end
