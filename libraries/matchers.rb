if defined?(ChefSpec)
  def install_apache_tomcat(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat, :install, res_name)
  end

  def remove_apache_tomcat(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat, :remove, res_name)
  end

  def create_apache_tomcat_instance(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat_instance, :create, res_name)
  end
end
