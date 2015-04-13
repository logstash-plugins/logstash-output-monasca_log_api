# Logstash Output Monasca-api Plugin
## Introduction
## Requirements
* Ruby (I recommend to use Ruby Version Manager (RVM) [https://rvm.io/])
* bundler

  ```
  gem install bundler
  ```

## Clone project
```bash
git clone git@estscm1.intern.est.fujitsu.com:teammonitoring/logstash-output-monasca_api.git
```

## Build project
```bash
bundle install
```

```bash
gem build logstash-output-monasca_api.gemspec
```

## Deploy to logstash

Download logstash (>=1.5.0.rc2) [http://download.elastic.co/logstash/logstash/logstash-1.5.0.rc2.tar.gz]

```bash
gem "logstash-output-monasca_api", :path => "/vagrant_home/cloudmonitor/logstash-output-monasca_api"
```

Run
```bash
bin/plugin install --no-verify
```

## Start logstash with output plugin
Run
```bash
bin/logstash -e 'input {stdin{}} output {monasca_api{}}'
```