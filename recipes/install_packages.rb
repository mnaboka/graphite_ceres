# Maksym Naboka 2014
# Cookbook Name:: graphite_ceres
# Recipe:: install_packages
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
include_recipe "python"

%w{pkg-config libffi-dev libcairo2}.each do |pkg|
  package "#{pkg}" do
    action :install
  end
end

%w{cairocffi}.each do |pip_pkg|
  python_pip pip_pkg do
    action :install
  end
end
