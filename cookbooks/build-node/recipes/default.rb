#
# Cookbook Name:: build-node
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_server_url = "https://chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"

append_if_no_line "Add certificate to authorized_keys" do
  path "/home/#{node['demo']['admin-user']}/.ssh/authorized_keys"
  line lazy { IO.read('/tmp/public.pub') }
end

directory '/etc/chef'
directory '/etc/chef/trusted_certs'

%w(chef-server delivery compliance).each do |f|
  file "/etc/chef/trusted_certs/#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content lazy { IO.read("/tmp/#{f}.crt") }
    action :create
  end
end

file '/etc/chef/client.pem' do
  content lazy { IO.read('/tmp/private.pem') }
  action :create
end

template '/etc/chef/client.rb' do
  source 'client.erb'
  variables(
    chef_server_url: chef_server_url,
    client_key: '/etc/chef/client.pem',
    node_name: "build-node-#{node['demo']['node-number']}"
  )
end

include_recipe 'wombat::etc-hosts'
include_recipe 'delivery_build::default'