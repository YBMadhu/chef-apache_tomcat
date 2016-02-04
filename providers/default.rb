#
# Cookbook Name:: apache_tomcat
# Provider:: default
#
# Copyright 2015 Brian Clark
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

use_inline_resources if defined?(use_inline_resources)

def whyrun_supported?
  true
end

[:install, :remove].each do |a|
  action a do
    [:version, :mirror, :checksum].each do |attrib|
      unless new_resource.instance_variable_get("@#{attrib}")
        new_resource.instance_variable_set("@#{attrib}", node['apache_tomcat'][attrib])
      end
    end

    tomcat_resource(a)
  end
end

private

def tomcat_resource(exec_action)
  version = new_resource.version
  tarball_name = "tomcat-#{version}.tar.gz"
  mirror = new_resource.mirror || node['apache_tomcat']['mirror']
  download_path = ::File.join(Chef::Config[:file_cache_path], tarball_name)
  extract_path = ::File.join(::File.dirname(new_resource.path), "tomcat-#{version}")

  remote_file download_path do
    source "#{mirror}/#{version}/tomcat-#{version}.tar.gz"
    owner 'root'
    group 'root'
    checksum new_resource.checksum || node['apache_tomcat']['checksum']
    only_if { exec_action == :install }
  end

  directory extract_path do # ~FC038
    owner 'root'
    group 'root'
    mode '0755'
    recursive true
    action exec_action == :install ? :create : :delete
  end

  bash 'extract tomcat' do
    user 'root'
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    tar xzf #{tarball_name} --strip-components 1 -C "#{extract_path}"
    cd "#{extract_path}"
    rm -rf logs temp work
    rm -rf bin/*.bat
    mv webapps bundled_webapps
    mv conf bundled_conf
    chmod 0644 bundled_conf/*
    EOH
    not_if { ::File.directory?(::File.join(extract_path, 'bin')) }
    only_if { exec_action == :install }
  end

  link new_resource.path do # ~FC038
    to extract_path
    action exec_action == :install ? :create : :delete
  end
end
