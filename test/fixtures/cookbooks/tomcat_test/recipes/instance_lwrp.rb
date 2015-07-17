node.default['tomcat_test']['instance_name'] = nil
apache_tomcat_instance 'tomcat-test' do
  instance_name node['tomcat_test']['instance_name']
  base node['apache_tomcat']['base']
  jmx_port node['apache_tomcat']['jmx_port']
  shutdown_port node['apache_tomcat']['shutdown_port']
  http_port node['apache_tomcat']['http_port']
  ssl_port node['apache_tomcat']['ssl_port']
  ajp_port node['apache_tomcat']['ajp_port']
end
