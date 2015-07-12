# apache_tomcat cookbook

Install and configure Tomcat using official Apache binaries. Multiple instances
are supported.

This cookbook does NOT use or depend on OS packages for Tomcat, nor does it
expect to play well with them. If using OS packages, use the
[tomcat](https://supermarket.chef.io/cookbooks/tomcat) cookbook instead.

## Requirements

### Platforms
This cookbook has been tested with the following platforms and service providers.
Other combinations of compatible platforms and service providers will likely
work with proper tweaking, but have not been tested:
* CentOS (6.6 - sysvinit, 7.0 - systemd)
* Ubuntu (14.04 - upstart)

### Dependencies
Required:
* [logrotate](https://supermarket.chef.io/cookbooks/logrotate)- used by the
`default` recipe to install logrotate
* [poise-service](https://supermarket.chef.io/cookbooks/poise-service) -
used to manage Tomcat service(s)

Suggested:
* `java` (see below)

#### Java
This cookbook does not install Java.  You should install Java earlier in your
runlist before consuming recipes/resources in this cookbook. For example...
* [java](https://supermarket.chef.io/cookbooks/java) community cookbook
* [oracle_jdk](https://github.com/bdclark/chef-oracle_jdk) - a cookbook dedicated
to installing the Oracle JDK

#### Logrotate
This cookbook depends on the [logrotate](https://supermarket.chef.io/cookbooks/logrotate)
cookbook but will only install logrotate when using the `default` recipe. If you
are using the `apache_tomcat_instance` LWRP you'll need to install logrotate on your own.

#### Poise-Service
This cookbook depends on [poise-service](https://supermarket.chef.io/cookbooks/poise-service)
to create and manage Tomcat service(s). On RHEL platforms < 7.0 (and Amazon
Linux), this cookbook defaults to the `:sysvinit` provider and includes a suitable
init template instead of using the poise-service default. The poise-service cookbook
allows a considerable amount of flexibility for setting/overriding service behavior,
init scripts, etc.  Refer to that cookbook's documentation for implementation
details.

## Recipes

### default
Installs and configures a single instance of Tomcat by including the `install`
and `configure` recipes explained below. Also includes the `logrotate` default
recipe to ensure logrotate is installed.

Tomcat is installed in `node['apache_tomcat']['install_path']` and becomes
CATALINA_HOME. An instance is created in `node['apache_tomcat']['instance_path']`
and becomes CATALINA_BASE. While not the default behavior, these two attributes
can be set to the same path if desired to install and run Tomcat from a single
directory.

### install
Only installs Tomcat binaries, and uses the following node attributes. See
`attributes/default.rb` for default values.

* `node['apache_tomcat']['install_path']` - directory to install Tomcat binaries
* `node['apache_tomcat']['mirror']` - url to apache Tomcat mirror
* `node['apache_tomcat']['version']` - Tomcat version
* `node['apache_tomcat']['checksum']` - sha256 checksum of downloaded tarball

Use this recipe to create a CATALINA_HOME as the basis for single or multiple instance of Tomcat.

### configure
Creates Tomcat service user/group and configures a single Tomcat instance in
`node['apache_tomcat']['instance_path']`. This recipe expects Tomcat to already
be installed in `node['apache_tomcat']['install_path']`.

This recipe uses the `apache_tomcat_instance` LWRP to configure Tomcat. Node
attributes are exposed for most all of the LWRP's configurable attributes. See
below for an explanation of the `apache_tomcat_instance` attributes and `attributes/instance.rb`
for the default values used in this recipe.

Use this recipe to configure Tomcat after installing with the `install` recipe,
or to configure Tomcat installed by some other means (e.g. an application
delivered with an embedded version of Tomcat).

## Resources / Providers

### apache_tomcat
Install or remove Tomcat binaries. In typical applications this is used to
create a CATALINA_HOME for one or more instances of Tomcat.

#### Actions
* `install` - Default action. Install Tomcat binaries into `path`
* `remove` - Uninstalls Tomcat binaries from `path`

#### Attributes
* `path` - Directory to install Tomcat binaries; default: name of resource block
* `mirror` - url to apache Tomcat mirror (defaults to node attribute)
* `version` - version of Tomcat to download/install (defaults to node attribute)
* `checksum` - sha256 checksum of downloaded tarball (defaults to node attribute)

### apache_tomcat_instance
Install and/or configure an instance of Tomcat. In typical applications this is
used to create one or more instances of Tomcat (CATALINA_BASE) after installing
Tomcat with the `apache_tomcat` LWRP.

#### Actions
* `create` - Default action. Install and configure Tomcat instance in `base`

#### Attributes
* `base` - required directory to create this Tomcat instance; default: name of
resource block (equiv. to CATALINA_BASE)
* `home` - required path to existing apahe binaries (equiv. to CATALINA_HOME)
* `service_name` - optional name of service (defaults to basename of `base`)
* `enable_service` - whether to enable/start service; default: `true`
* `user` - Tomcat service user; default: `tomcat`
* `group` - Tomcat service group; default: `tomcat`
* `webapps_mode` - optional permissions for webapps directory; default: `0775`
* `enable_manager` - whether to enable manager webapp by copying from `home`
to `base`; default: `false`
* `log_dir` - optional directory for Tomcat logs; must be absolute if specified
* `logrotate_frequency` - rotation frequency; default: `weekly`
* `logrotate_count` - logrotate file count; default: `4`
* `kill_delay` - seconds to wait before kill -9 on service stop/restart; default: 45 (integer)
* `initial_heap_size` - optional java initial heap size (-Xms) added to CATALINA_OPTS
* `max_heap_size` - optional java max heap size (-Xmx) added to CATALINA_OPTS
* `max_perm_size` - optional java max permanent size (-XX:MaxPermSize) added to CATALINA_OPTS
* `catalina_opts` - optional string or array of CATALINA_OPTS in setenv.sh
* `java_opts` - optional string or array of JAVA_OPTS in setenv.sh
* `java_home` - optional JAVA_HOME in setenv.sh
* `jmx_port` - JMX report port (integer); default: `nil` (JMX management is disabled if `nil`)
* `jmx_authenticate` - whether JMX authentication is enabled; default: `true`
(ignored unless `jmx_port` set)
* `jmx_monitor_password` - password for JMX readonly access; default: `nil`
(ignored unless `jmx_port` set and `jmx_authenticate` true)
* `jmx_control_password` - password for JMX readwrite access; default: `nil`
(ignored unless `jmx_port` set and `jmx_authenticate` true)
* `jmx_dir` - optional directory for jmxremote.password and jmxremote.access,
defaults to `home`/conf
* `shutdown_port` - Tomcat shutdown port in server.xml; required
* `http_port` - optional http port (integer), http connector undef
* `ajp_port` - optional ajp port (integer)
* `ssl_port` - optional ssl port (integer)
* `pool_enabled` - enable shared executor (thread pool); default: `false`
* `access_log_enabled` - whether to enable access log valve; default: `false`
* `http_additional` - hash of additional http connector attributes
* `ajp_additional` - hash of additional ajp connector attributes
* `ssl_additional` - hash of addtional ssl connector attributes
* `pool_additional` - hash of additional executor (thread pool) attributes
* `access_log_additional` - hash of additional access log valve attributes
* `engine_valves` - nested hash of one or more engine valves
* `host_valves` - nested hash of one or more host valves
* `tomcat_users` - optional array of Tomcat-users (see below for expected format)

Additionally, the following attributes allow you override the included templates
with your own. Use `name` to reference a template in the calling cookbook or
`cookbook:name` to reference a template in another cookbook:
* `setenv_template` - bin/setenv.sh
* `server_xml_template` - conf/server.xml
* `logging_properties_template` - conf/logging.properties
* `tomcat_users_template` - conf/tomcat-users.xml
* `logrotate_template` - /etc/logrotate.d/`service_name`

## Usage and examples
Install Tomcat 7.0.56 binaries in /usr/local/tomcat7; create an instance in /var/lib/tomat1 with service Tomcat1 running as user Tomcat:
```
apache_tomcat '/usr/local/tomcat7' do
  version '7.0.56'
end

apache_tomcat_instance '/var/lib/tomcat1' do
  home 'usr/local/tomcat7'
  user 'tomcat'
  group 'tomcat'
  http_port 8080
end
```
The example above will use `/usr/local/tomcat7` as CATALINA_HOME and
`/var/lib/tomcat1` as CATALINA_BASE.


#### HTTP Connector
To define a non-SSL HTTP Connector, set `http_port` to a port number. If `nil` the
connector will not be created in server.xml. To specify additional attributes
for this connector, specify them using `http_additional`. For example:
```
node['apache_tomcat']['http_port'] = 8080
```
will generate the following connector using cookbook defaults:
```
<Connector port="8080"
           protocol="HTTP/1.1"
           connectionTimeout="20000"
           URIEncoding="UTF-8"
           />
```
To override connector attributes, or to add additional ones, use `http_additional`:
```
node['apache_tomcat']['http_port'] = 8080
node['apache_tomcat']['http_additional']['protocol'] = 'org.apache.coyote.http11.Http11NioProtocol'
node['apache_tomcat']['http_additional']['connectionTimeout'] = '15000'
node['apache_tomcat']['http_additional']['address'] = '10.0.0.5'
```
creates the following connector:
```
<!-- Define a non-SSL HTTP Connector on port 8080 -->
<Connector port="8080"
           protocol="org.apache.coyote.http11.Http11NioProtocol"
           connectionTimeout="15000"
           URIEncoding="UTF-8"
           address="10.0.0.5"
           />
```
Of course if desired it can also be specified with a raw hash:
```
node['apache_tomcat']['http_additional'] = {
  'protocol' => 'org.apache.coyote.http11.Http11NioProtocol',
  'connectionTimeout' => '15000',
  'address' => '10.0.0.5'
}
```

#### SSL Connector
An SSL connector can be specified in much the same way as the HTTP connector
examples shown above, using `ssl_port` and `ssl_additional`. If only `ssl_port`
is specified, the default settings for the connector are:
```
<!-- Define an SSL Connector on port xxxx -->
<Connector port="xxxx"
           protocol="HTTP/1.1"
           connectionTimeout="20000"
           URIEncoding="UTF-8"
           SSLEnabled="true"
           scheme="https"
           secure="true"
           sslProtocol="TLS"
           clientAuth="false"
           />
```
If desired these can be overridden with `ssl_additional`.

*NOTE:* If the ssl connector is enabled, it will by default add the `redirectPort`
attribute to the http connector (and the ajp connector if enabled) with the value
set to the `ssl_port`.

#### AJP Connector
TODO
#### Thread Pool
TODO

#### Tomcat users
The `tomcat_users` attribute accepts an array of user hashes like so:
```
[
  {
    'id' => 'frank',
    'password' => 'bacon',
    'roles' => ['admin']
  },
  {
    'id' => 'bob',
    'password' => 'eggs',
    'roles' => ['admin', 'foo']
  }
]
```
While it's possible to set `node['apache_tomcat']['tomcat_users']` node attribute
for use with the `default` or `configure` recipes, it's probably not a good idea.
The attribute is more suited for `apache_tomcat_instance` LWRP consumers...
setting the LWRP attribute from a data bag or some other means in a wrapper cookbook.
Support for setting tomcat_users from a data bag (or even run_state) for use with
the default and configure recipes may be considered in the future.

## License and Authors
- Author:: Brian Clark (brian@clark.zone)

```text
Copyright 2015, Brian Clark

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
