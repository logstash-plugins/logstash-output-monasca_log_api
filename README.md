# Logstash Output Monasca-Log-Api Plugin

## Build from source

### Requirements

* JRuby (I recommend to use Ruby Version Manager (RVM) How to install? ->  https://rvm.io/rvm/install)
* JDK
* Git
* bundler

### How to install the requirements

#### Ubuntu 14.04

##### RVM
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash
source /home/vagrant/.rvm/scripts/rvm
```

#### Git
```bash
sudo apt-get install git
```

#### JDK
```bash
sudo apt-get install default-jdk
```

#### JRuby
```bash
rvm install jruby
```

### Clone project

```bash
git clone https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/logstash-output-monasca_api.git
```

### Use rvm jruby
```bash
rvm use jruby
```

### Install bundler
```bash
gem install bundler
```

### Fetch dependencies
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

## Deploy Plugin to logstash

### Build Gemfile
First we need to create a Gemfile.

What is a Gemfile? Gems are packages for the Ruby programming language. A Gemfile defines all dependencies which are neccessary to build the product.

How to build a Gemfile? Run this:
```bash
gem build logstash-output-monasca_log_api.gemspec
```

### Deploy Gemfile to logstash

* [Download logstash](http://download.elastic.co/logstash/logstash/logstash-1.5.0.tar.gz) (>=1.5.0)
* Extract logstash and navigate into the folder
* Add this line to the Gemfile

  ```bash
  gem "logstash-output-monasca_log_api", :path => "/vagrant_home/cloudmonitor/logstash-output-monasca_log_api"
  ```

  * __logstash-output-monasca_log_api__ = name of the gem
  * __/vagrant_home/cloudmonitor/logstash-output-monasca_log_api__ = Path to git workspace

Run this command from logstash folder to install the plugin
```bash
bin/plugin install --no-verify
```

Verify installed plugins:
With ``bin/plugin list`` you can check installed plugins. There should be ``logstash-output-monasca_log_api``.

## Start logstash output plugin

### Configuration

Save the configfile wherever you like. For example ~/logstash.conf

| name | description | required | example |
| - | - | - | - |
| monasca_log_api | monasca log api url | yes | http://192.168.10.4:8080 |
| keystone_api | keystone api url | yes | http://192.168.10.5:5000 |
| project_name | User-credentials: keystone project name | yes | mini-mon |
| username | User-credentials: keystone username | yes | admin-agent |
| password | User-credentials: keystone user password | yes | password |
| domain_id | User-credentials: keystone user domain-id | yes | default |
| dimensions | Dictionary of key-value pairs to describe logs | no | hostname: monasca, ip: 192.168.10.4 |
| application_type_key | Application name | no | monasca |

#### Example file
```bash
input {
  stdin { }
}
output {
  monasca_log_api {
    monasca_log_api => "http://192.168.10.4:8080"
    keystone_api => "http://192.168.10.5:5000"
    project_name => "mini-mon"
    username => "admin-agent"
    password => "password"
    domain_id => "default"
    dimensions => "hostname: elkstack, ip: 192.168.10.4"
    application_type_key => "monasca"
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
### Logstash Input plugins
https://www.elastic.co/guide/en/logstash/current/input-plugins.html

## Open tasks
* Language translations (Replace hardcoded String messages with a configuration/language file)
* Exception handling (monasca-api requests)
* Contribute to logstash http://www.elastic.co/guide/en/logstash/master/_how_to_write_a_logstash_output_plugin.html#_contributing_your_source_code_to_ulink_url_https_github_com_logstash_plugins_logstash_plugins_ulink_4
