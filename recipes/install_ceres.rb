# Maksym Naboka 2014
# Cookbook Name:: graphite_ceres
# Recipe:: install_ceres
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

ceres = 'ceres'
git "#{Chef::Config[:file_cache_path]}/#{ceres}" do
  repository node['graphite']['ceres']['git']
  reference node['graphite']['ceres']['branch']
  action :checkout
  notifies :run, "execute[install_ceres_dependancies]", :immediately
end

execute "install_ceres_dependancies" do
  command "pip install -r #{ceres}/requirements.txt"
  cwd Chef::Config[:file_cache_path]
  action :nothing
end

execute "python_install_ceres" do
  command "python setup.py install --prefix=#{node['graphite']['base_dir']}"
  cwd Chef::Config[:file_cache_path] + "/#{ceres}"
  creates "#{node['graphite']['base_dir']}/bin/ceres-tree-create"
end
