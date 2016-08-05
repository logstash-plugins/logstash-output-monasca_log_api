Gem::Specification.new do |s|
  s.name = 'logstash-output-monasca_log_api'
  s.version = '0.5.2'
  s.licenses = ['Apache-2.0']
  s.summary = 'This gem is a logstash output plugin to connect via http to monasca-log-api.'
  s.description = 'This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program'
  s.authors = ['Fujitsu Enabling Software Technology GmbH']
  s.email = 'kamil.choroba@est.fujitsu.com,tomasz.trebski@ts.fujitsu.com'
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/FujitsuEnablingSoftwareTechnologyGmbH/logstash-output-monasca_api'

  # Files
  s.files = Dir["lib/**/*", "spec/**/*", "*.gemspec", "*.md", "Gemfile", "LICENSE"]

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'logstash_group' => 'output' }

  # Gem dependencies
  s.add_runtime_dependency 'logstash-core', '~> 2.0'
  s.add_runtime_dependency 'logstash-codec-plain', '~> 2.0'
  s.add_runtime_dependency 'logstash-codec-json', '~> 2.0'
  s.add_runtime_dependency 'vine', '~> 0.2'
  s.add_development_dependency 'logstash-devutils', '~> 0.0.14'
  s.add_development_dependency 'simplecov', '~> 0.10'
  s.add_development_dependency 'rubocop', '~> 0.37.2'
  s.add_development_dependency 'webmock', '~> 2.0'
end
