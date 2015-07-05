if defined?(ChefSpec)
  def create_apache_tomcat(res_name)
    ChefSpec::Matchers::ResourceMatcher.new(:apache_tomcat, :create, res_name)
  end
end
