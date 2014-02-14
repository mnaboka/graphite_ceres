#
# Cookbook Name:: graphite_ceres
# Recipe:: setup_webapp
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
basedir = node['graphite']['base_dir']
docroot = node['graphite']['doc_root']
storagedir = node['graphite']['storage_dir']
version = node['graphite']['version']

if node['graphite']['web_server'] == 'apache'
  graphite_web_service_resource = 'service[apache2]'
else
  graphite_web_service_resource = 'runit_service[graphite-web]'
end

password = node['graphite']['web']['password']
if node['graphite']['encrypted_data_bag']['name']
  data_bag_name = node['graphite']['encrypted_data_bag']['name']
  data_bag_item = Chef::EncryptedDataBagItem.load(data_bag_name, 'graphite')
  password = data_bag_item['web_password']
else
  Chef::Log.warn 'This recipe uses encrypted data bags for graphite password but no encrypted data bag name is specified - fallback to node attribute.'
end

%w{ info.log exception.log access.log error.log }.each do |file|
  file "#{storagedir}/log/webapp/#{file}" do
    owner node['graphite']['user_account']
    group node['graphite']['group_account']
  end
end

template "#{docroot}/graphite/local_settings.py" do
  source 'local_settings.py.erb'
  mode 00755
  notifies :reload, graphite_web_service_resource
end

template "#{docroot}/graphite/settings.py" do
  source 'settings.py.erb'
  mode 00755
  notifies :reload, graphite_web_service_resource
end

template "#{basedir}/conf/graphTemplates.conf" do
  source 'graphTemplates.conf.erb'
  mode 00755
  variables(
    :graph_templates => node['graphite']['graph_templates']
  )
  notifies :reload, graphite_web_service_resource
end

template "#{basedir}/bin/set_admin_passwd.py" do
  source 'set_admin_passwd.py.erb'
  mode 00755
end

template "#{basedir}/conf/graphite.wsgi" do
  source 'graphite.wsgi.erb'
  mode 00755
end

cookbook_file "#{storagedir}/graphite.db" do
  action :create_if_missing
  notifies :run, 'execute[set admin password]'
end

execute 'set admin password' do
  command "#{basedir}/bin/set_admin_passwd.py root #{password}"
  environment  "PYTHONPATH" => "#{node['graphite']['doc_root']}" 
  action :nothing
end

# This is not done in the cookbook_file above to avoid triggering a password set on permissions changes
file "#{storagedir}/graphite.db" do
  owner node['graphite']['user_account']
  group node['graphite']['group_account']
  mode 00644
end

if node['graphite']['web_server'] == 'apache'
  include_recipe 'graphite_ceres::apache'
else
  include_recipe 'graphite_ceres::uwsgi'
end
