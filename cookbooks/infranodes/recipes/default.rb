#
# Cookbook Name:: infranodes
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

chef_ingredient 'chef' do
  channel :stable
  action :install
  version node['demo']['versions']['chef']
end

include_recipe 'push-jobs'

chef_server_url = "https://chef-server.#{node['demo']['domain']}/organizations/#{node['demo']['org']}"
delivery_server_url = "https://delivery.#{node['demo']['domain']}/e/#{node['demo']['enterprise']}"

template '/etc/chef/client.rb' do
  source 'client.rb.erb'
  variables({
      :chef_server_url => chef_server_url,
      :name => node['demo']['node_name'],
      :delivery_server_url => delivery_server_url
  })
end

file '/etc/chef/client.pem' do
  content IO.read('/tmp/private.pem')
end

###todo: centralize this into the wombat cookbook
directory '/etc/chef/trusted_certs'

%w(chef-server delivery compliance).each do |f|
  file "/etc/chef/trusted_certs/#{f}_#{node['demo']['domain'].tr('.','_')}.crt" do
    content IO.read("/tmp/#{f}.crt")
  end
end
###

include_recipe 'wombat::etc-hosts'