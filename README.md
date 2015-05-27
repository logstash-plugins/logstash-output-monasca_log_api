# Logstash Output Monasca-api Plugin
## Introduction
Gitlab: [http://estscm1.intern.est.fujitsu.com/teammonitoring/logstash-output-monasca_api]

Jenkins: [http://estesscsijen:8080/job/Logstash-Output-Monasca_Api/]

## Requirements
Install:
* Ruby (I recommend to use Ruby Version Manager (RVM) How to install? -> Read this: [https://rvm.io/rvm/install])
* bundler, how to install?

  ```
  gem install bundler
  ```

## Clone project
```bash
git clone git@estscm1.intern.est.fujitsu.com:teammonitoring/logstash-output-monasca_api.git
```

## Build the project with:
```bash
rake build
```

## Run unit tests with:
```bash
rake test
```

### Run specified test
```bash
bundle exec rspec spec/outputs/monasca/monasca_api_client_spec.rb
```

## Deploy Gemfile to logstash

First we need to create a Gemfile.

What is a Gemfile? Gems are packages for the Ruby programming language. A Gemfile defines all dependencies which are neccessary to build the product.

How to build a Gemfile? Run this:
```bash
gem build logstash-output-monasca_api.gemspec
```

## Deploy Gemfile to logstash

* Download logstash (>=1.5.0.rc2) [http://download.elastic.co/logstash/logstash/logstash-1.5.0.rc2.tar.gz]
* Extract logstash and navigate into the folder
* Add this line to the Gemfile

  ```bash
  gem "logstash-output-monasca_api", :path => "/vagrant_home/cloudmonitor/logstash-output-monasca_api"
  ```
  * logstash-output-monasca_api = name of the gem
  * "/vagrant_home/cloudmonitor/logstash-output-monasca_api" = Path to git workspace

Run this command to install the plugin
```bash
bin/plugin install --no-verify
```

## Start logstash output plugin
### Simple Configuration File
```bash
input {
  stdin { }
}
output {
  monasca_api {
    monasca_host => "192.168.10.4"
    monasca_port => 8080
    keystone_host => "192.168.10.5"
    keystone_port => 5000
    project_id => "123456"
    user_id => "987654"
    password => "password"
    dimensions => "hostname: elkstack, ip: 192.168.10.4"
  }
}
```
Run
```bash
bin/logstash -f path-to-configuration-file
```
### Logstash Input plugins
[https://www.elastic.co/guide/en/logstash/current/input-plugins.html]

## Open tasks
* Language translations (Replace hardcoded String messages with a configuration/language file)
* Exception handling
* Contribute to logstash [http://www.elastic.co/guide/en/logstash/master/_how_to_write_a_logstash_output_plugin.html#_contributing_your_source_code_to_ulink_url_https_github_com_logstash_plugins_logstash_plugins_ulink_4]