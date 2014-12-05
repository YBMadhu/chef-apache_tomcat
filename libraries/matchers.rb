if defined?(ChefSpec)
  def install_tomcat_bin(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_bin, :install, res_name)
  end

  def configure_tomcat_bin(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_bin, :configure, res_name)
  end

  def restart_tomcat_bin(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_bin, :restart, res_name)
  end
end
