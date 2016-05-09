name             'apache_tomcat'
maintainer       'Brian Clark'
maintainer_email 'brian@clark.zone'
license          'apache2'
description      'Installs/Configures Apache Tomcat'
long_description 'Installs/Configures Apache Tomcat'
version          '0.3.1'

supports 'ubuntu'
supports 'centos'

depends 'logrotate'
depends 'poise-service', '~> 1.0'
