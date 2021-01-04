# logstash-output-monasca_log_api

[![Travis Build Status](https://travis-ci.com/logstash-plugins/logstash-output-monasca_log_api.svg)](https://travis-ci.com/logstash-plugins/logstash-output-monasca_log_api)

This module is a logstash-output-plugin for the Monasca Log Api.

Compatible logstash version: [Logstash 7.x](https://www.elastic.co/downloads/logstash)

## Get latest stable version
https://rubygems.org/gems/logstash-output-monasca_log_api

```bash
gem install logstash-output-monasca_log_api
```

## Build from source

### Requirements

* JRuby (I recommend to use Ruby Version Manager (RVM) How to install? ->  https://rvm.io/rvm/install)
* JDK
* Git
* bundler

### Install requirements

#### RVM
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash
source /home/vagrant/.rvm/scripts/rvm
```

#### JRuby
```bash
rvm install jruby
```

#### Clone project

```bash
git clone https://github.com/logstash-plugins/logstash-output-monasca_log_api.git
```

#### Use jruby
```bash
rvm use jruby
```

#### Install bundler
```bash
gem install bundler
```

#### Fetch dependencies
```bash
bundle install
```

## Unit tests

### Run unit tests with:
```bash
bundle exec rspec
```

### Run specified test
```bash
bundle exec rspec spec/outputs/monasca/monasca_log_api_client_spec.rb
```

### Run coverage
```bash
JRUBY_OPTS="-Xcli.debug=true --debug" bundle exec rspec
```

Coverage report can be found in ./coverage

### Code style check
```bash
rubocop lib/
```

## Deploy Plugin to logstash

Source: [https://www.elastic.co/guide/en/logstash/current/_how_to_write_a_logstash_output_plugin.html#_building_and_testing_4](https://www.elastic.co/guide/en/logstash/current/_how_to_write_a_logstash_output_plugin.html#_building_and_testing_4)

### Build Gemfile
First we need to create a Gemfile.

What is a Gemfile? Gems are packages for the Ruby programming language. A Gemfile defines all dependencies which are neccessary to build the product.

How to build a Gemfile? Run this:
```bash
gem build logstash-output-monasca_log_api.gemspec
```

### Deploy Gemfile to logstash

* [Download logstash](https://download.elastic.co/logstash/logstash/logstash-2.3.4.tar.gz) (>=2.3.4)
* Extract logstash and navigate into the folder

Run this command from logstash folder to install the plugin
```bash
bin/logstash-plugin install /my/logstash/plugins/logstash-output-monasca_log_api-1.0.0.gem
```

Verify installed plugins:
With ``bin/plugin list --verbose`` you can check installed plugins. There should be ``logstash-output-monasca_log_api``.

## Start logstash output plugin

### Configuration

Plugin name: monasca_log_api

Save the configfile wherever you like. For example ~/logstash.conf

| name | description | type | required | default | example |
| --- | --- | --- | --- | --- | --- |
| monasca_log_api_url | monasca log api url | string | true | | https://192.168.10.4:5607/v3.0 |
| monasca_log_api_insecure | set to true if monasca-log-api is using an insecure ssl certificate  | boolean | false | false | |
| keystone_api_url | keystone api url | string | true | | http://192.168.10.5:35357/v3 |
| keystone_api_insecure | set to true if keystone is using an insecure ssl certificate | boolean | false | false | |
| project_name | Keystone user credentials: project name | string | true | | monasca |
| username | Keystone user credentials: username | string | true | | admin-agent |
| password | Keystone user credentials: password | string | true | | password |
| user_domain_name | Keystone user credentials: user domain name | string | true | | default |
| project_domain_name | Keystone user credentials: project domain name | string | true | | default |
| dimensions | global array dimensions in form of key-value pairs to describe the monitored node | array | false | | ['app_type:kafka', 'priority:high'] |
| num_of_logs | maximum number of logs that are send by one request to monasca-log-api | number | false | 125 | |
| elapsed_time_sec | send logs if the maximum elapsed time in seconds is reached | number | false | 30 | |
| delay | delay time in seconds to wait before checking the elapsed_time_sec again | number | false | 10 | |
| max_data_size_kb | maximum size in kb of logs that are send by one request to monasca-log-api | number | false | 5120 | |

#### Example configuration files

##### Simple
```bash
output {
  monasca_log_api {
    monasca_log_api_url => "http://192.168.10.4:5607/v3.0"
    keystone_api_url => "http://192.168.10.5:35357/v3"
    project_name => "cmm"
    project_domain_name => "Default"
    username => "cmm-operator"
    user_domain_name => "Default"
    password => "admin"
  }
}
```

##### Complete
```bash
output {
  monasca_log_api {
    monasca_log_api_url => "https://192.168.10.4:5607/v3.0"
    monasca_log_api_insecure => true
    keystone_api_url => "http://192.168.10.5:35357/v3"
    keystone_api_insecure => false
    project_name => "cmm"
    project_domain_name => "Default"
    username => "cmm-operator"
    user_domain_name => "Default"
    password => "admin"
    dimensions => ["hostname: monasca", "ip:192.168.10.4"]
    num_of_logs => 125
    delay => 10
    elapsed_time_sec => 30
    max_data_size_kb => 5120
  }
}
```

Run
```bash
bin/logstash -f ~/logstash.conf
```

Run in debug mode
```bash
bin/logstash -f ~/logstash.conf --debug
```

Specify log output file
```bash
bin/logstash -f ~/logstash.conf -l /var/log/monasca/log/agent/test-log-agent.log
```

### Logstash File Input plugin
https://www.elastic.co/guide/en/logstash/current/plugins-inputs-file.html

#### Configuration

Local dimensions can be added with ```add_field``` setting

```bash
input {
  file {
    add_field => { "dimensions" => { "service" => "monasca-api" }}
    add_field => { "dimensions" => { "language" => "java" }}
    add_field => { "dimensions" => { "log_level" => "error" }}
    path => "/var/log/monasca/api/error.log"
    }
  }
```

#### Cross tenant functionality

The output plugin is able to post data on behalf of another tenant to the monasca-log-api.
For example you can use a user of tenant X to send logs to the monasca-log-api for another tenant Y. The logs will be stored in the index of tenant Y.

To use this functionality you need to pass through another field called ```cross_tenant``` to each incoming event. This can be done by using the ```add_field``` for file [input plugin](https://www.elastic.co/guide/en/logstash/2.4/plugins-inputs-file.html). Example configuration:

```bash
input {
  file {
    add_field => { "dimensions" => { "service" => "neutron" "component" => "firewall" }}
    add_field => { "cross_tenant" => "903ac629d8424dc39ae928a5fff338e7" }
    path => "/var/log/neutron/firewall.log"
  }
}
```

**Important:** The user which is sending the data on behalf of other tenants requires a specific role. This role is defined in the configuration file of the monasca-log-api as ```delegate_roles```.

#### Exception handling

This output plugin will sleep for maximum 60 seconds after the request to
Monasca API fails and will retry the request until successful.

## Open tasks
* Language translations (Replace hardcoded String messages with a configuration/language file)
* Unit tests for failed requests handling
