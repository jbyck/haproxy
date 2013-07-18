#
# Cookbook Name:: haproxy
# Recipe:: app_lb
#
# Copyright 2011, Opscode, Inc.
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

# Get frontend servers
pool_members = member_search(node[:haproxy][:app_server_role])
# load balancer may be in the pool
pool_members << node if node.run_list.roles.include?(node[:haproxy][:app_server_role])

# Get servers for custom ACLs, if applicable
# If a server role (acl_server) is not specified, skip
acl_members = {}
node[:haproxy][:custom_acls].each do |acl|
  Chef::Log.info "Searching for nodes for #{acl[:name]} #{acl_name(acl)}"
  next unless acl.key?(:acl_server)
  acl_members[acl_name(acl).to_sym] = member_search(acl[:acl_server])
  acl_members[acl_name(acl).to_sym] << node if node.run_list.roles.include?(acl[:acl_server])
end

Chef::Log.info "ACL members #{acl_members.inspect}"

# Use returned Chef nodes to extract data from member we need to build config (through lib function) 
pool_members.map! { |member| member_data(member) }.uniq!

acl_members.each do |key, members|
  members.map! { |member| member_data(member) }.uniq!
end

package "haproxy" do
  action :install
end

cookbook_file "/etc/default/haproxy" do
  source "haproxy-default"
  owner "root"
  group "root"
  mode 00644
  notifies :restart, "service[haproxy]"
end

template "/etc/haproxy/haproxy.cfg" do
  source "haproxy-app_lb.cfg.erb"
  owner "root"
  group "root"
  mode 00644
  variables(
    :pool_members => pool_members,
    :defaults_options => defaults_options,
    :defaults_timeouts => defaults_timeouts,
    :acls => node[:haproxy][:custom_acls],
    :acl_members => acl_members
  )
  notifies :restart, "service[haproxy]"
end

include_recipe 'haproxy::logs' 

service "haproxy" do
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end
