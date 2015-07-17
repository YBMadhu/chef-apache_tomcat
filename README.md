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
used to manage Tomcat service(s) (see below)

Suggested:
* `java` (see below)

#### Java
This cookbook does not install Java.  You should install Java earlier in your
runlist before consuming recipes/resources in this cookbook. For example...
* [java](https://supermarket.chef.io/cookbooks/java) community cookbook
* [oracle_jdk](https://github.com/bdclark/chef-oracle_jdk) - a cookbook dedicated
to installing the Oracle JDK

#### Poise-Service
This cookbook depends on [poise-service](https://supermarket.chef.io/cookbooks/poise-service)
to create and manage Tomcat service(s). On RHEL platforms < 7.0 (and Amazon
Linux), this cookbook defaults to the `:sysvinit` provider and includes a suitable
init template instead of using the poise-service default. The poise-service cookbook
allows a considerable amount of flexibility for setting/overriding service behavior,
init scripts, etc.  Refer to that cookbook's documentation for implementation
details.

## Attributes
* `mirror` - Tomcat mirror URL
* `version` - version of Tomcat to download/install
* `checksum` - sha256 checksum of downloaded Tomcat tarball
* `home` - installation path of Tomcat (equiv. to CATALINA_HOME)
* `base` - default CATALINA_BASE path for base instance
* `run_base_instance` - whether to run an instance in `base`
* `create_service_user` - whether to create service user/group specified in
`user` and `group` attributes

Attributes for Tomcat instance(s):
* `shutdown_port` - Shutdown port (integer)
* `http_port` - HTTP port (integer)
* `ssl_port` - SSL port (integer)
* `ajp_port` - AJP port (integer)
* `jmx_port` - JMX port (integer); default: `nil` (JMX management is disabled if `nil`)
* `user` - service user for Tomcat instances; default: `tomcat`
* `group` - primary group of service user; default: `tomcat`
* `webapps_mode` - optional permissions for webapps directory; default: `0775`
* `enable_manager` - whether to enable manager webapp by copying from `home`
to `base`; default: `false`
* `log_dir` - optional directory for Tomcat logs; must be absolute if specified
* `logrotate_frequency` - rotation frequency; default: `weekly`
* `logrotate_count` - logrotate file count; default: `4`
* `kill_delay` - seconds to wait before kill -9 on service stop/restart; default: 45 (integer)
* `initial_heap_size` - optional java initial heap size; adds `-Xms` CATALINA_OPTS
* `max_heap_size` - optional java max heap size; adds `-Xmx` to CATALINA_OPTS
* `max_perm_size` - optional java max permanent size; adds `-XX:MaxPermSize` to CATALINA_OPTS
* `catalina_opts` - optional string or array of CATALINA_OPTS in setenv.sh
* `java_opts` - optional string or array of JAVA_OPTS in setenv.sh
* `java_home` - optional JAVA_HOME environment variable in setenv.sh
* `jmx_authenticate` - whether JMX authentication is enabled; default: `true`
(ignored unless `jmx_port` set)
* `jmx_monitor_password` - password for JMX readonly access; default: `nil`
(ignored unless `jmx_port` set and `jmx_authenticate` true)
* `jmx_control_password` - password for JMX readwrite access; default: `nil`
(ignored unless `jmx_port` set and `jmx_authenticate` true)
* `jmx_dir` - optional directory for jmxremote.password and jmxremote.access,
defaults to `home`/conf
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

## Usage
Include the default recipe to install and configure Tomcat.

Tomcat will be installed in `home`, and becomes CATALINA_HOME. If `run_base_instance`
is `true`, an instance will be created in `base` and becomes CATALINA_BASE. The
instance will be configured using the instance-related node attributes listed
above.

A Tomcat service user/group will also be created if `create_service_user` is `true`.

## Multiple Instances
To run multiple instances of Tomcat, populate the instances attribute, which is
a dictionary of instance name => array of attributes. Most of the same attributes
that can be used globally for the tomcat cookbook can also be set per-instance -
see `resources/instance.rb` for detail.

IF the `base` attribute is NOT set for a particular instance, it will be derived
from `node['apache_tomcat']['base']`. For example, for instance 'instance1' if
`node['apache_tomcat']['base']` is /var/lib/tomcat, then `base` for 'instance1'
will be set to /var/lib/instance1.

The port attributes - `http_port`, `ssl_port`, `ajp_port`, `jmx_port`, and
`shutdown_port` - are not inherited from node attributes and must be set per-instance
if they are to be used. Other attributes for an instance that aren't set are
inherited unmodified from global node attributes.

If you only want to run specific instances and not the base instance specified
in `node['apache_tomcat']['base']`, set `run_base_instance` to `false`.

Example of partial role:
```
...
"override_attributes": {
  "apache_tomcat": {
    "run_base_instance": false,
    "http_additional": {
      "protocol": "org.apache.coyote.http11.Http11NioProtocol"
    },
    "instances": {
      "instance1": {
        "http_port": 8081,
        "shutdown_port": 8006
      },
      "instance2": {
        "http_port": 8082,
        "shutdown_port": 8007,
        "catalina_opts": [
          "-XX:+UseConcMarkSweepGC"
        ]
      }
    },
    ...
  }
  ...
}
```

## Resources / Providers

### apache_tomcat
Install or remove Tomcat binaries. In typical applications this is used to
create a CATALINA_HOME for one or more instances of Tomcat.

#### Actions
* `install` - Default action. Install Tomcat binaries into `path`
* `remove` - Uninstalls Tomcat binaries from `path`

#### Attributes
* `path` - Directory to install Tomcat binaries; default: name of resource block
* `mirror`, `version`, `checksum` - see Attributes above; inherits from node
attributes if not specified.

### apache_tomcat_instance
Install and/or configure an instance of Tomcat. In typical applications this is
used to create one or more instances of Tomcat (CATALINA_BASE) after installing
Tomcat with the `apache_tomcat` LWRP.

#### Actions
* `create` - Default action. Install and configure Tomcat instance in `base`

#### Attributes
The following attributes are specific to each instance and are not inherited
from node attributes:
* `instance_name` - name of service; default: name of resource block
* `base` - directory to create this Tomcat instance;
default: dirname of `node['apache_tomcat']['base']` + `instance_name`

Additional attributes for this resource are described in Attributes above.

## Attribute Examples

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
Support for setting tomcat_users from a data bag (or run_state) for use with
the default recipe may be considered in the future.

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
