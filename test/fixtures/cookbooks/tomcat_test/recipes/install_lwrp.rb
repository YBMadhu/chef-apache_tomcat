apache_tomcat 'test_tomcat' do
  path node['tomcat_test']['path']
  mirror node['tomcat_test']['mirror']
  version node['tomcat_test']['version']
  checksum node['tomcat_test']['checksum']
end
