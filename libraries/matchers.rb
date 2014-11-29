if defined?(ChefSpec)
  def configure_tomcat_bin(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_bin, :configure, res_name)
  end
end
