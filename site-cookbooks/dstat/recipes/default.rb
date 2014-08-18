#
# Cookbook Name:: dstat
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "yum-epel"

package "dstat" do
  action :install
end

