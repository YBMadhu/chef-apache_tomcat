if defined?(ChefSpec)
  def create_tomcat_bin(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:tomcat_bin, :create, res_name)
  end
end
