Gem::Specification.new do |s|
  s.name = 'logstash-output-monasca_log_api'
  s.version         = '1.0.4'
  s.licenses = ['Apache-2.0']
  s.summary = 'This gem is a logstash output plugin to connect via http to monasca-log-api.'
  s.description = 'This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program'
  s.authors = ['Fujitsu Enabling Software Technology GmbH']
  s.email = 'kamil.choroba@est.fujitsu.com,witold.bedyk@est.fujitsu.com'
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/logstash-plugins/logstash-output-monasca_log_api'

  # Files
  s.files = Dir["lib/**/*","spec/**/*","*.gemspec","*.md","CONTRIBUTORS","Gemfile","LICENSE","NOTICE.TXT", "vendor/jar-dependencies/**/*.jar", "vendor/jar-dependencies/**/*.rb", "VERSION", "docs/**/*"]

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'output' }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core', '~> 7.1'
  s.add_runtime_dependency 'logstash-codec-plain', '~> 3.0'
  s.add_runtime_dependency 'logstash-codec-json', '~> 3.0'
  s.add_runtime_dependency 'logstash-codec-multiline', '~> 3.0'
  s.add_runtime_dependency 'stud', '~> 0.0.22'
  s.add_development_dependency 'logstash-devutils', '~> 0.0.14'
  s.add_development_dependency 'simplecov', '~> 0.10'
  s.add_development_dependency 'simplecov-rcov', '~> 0.2.0'
  s.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  s.add_development_dependency 'rubocop', ">= 0.60.0"
  s.add_development_dependency 'webmock', '~> 2.0'
end
