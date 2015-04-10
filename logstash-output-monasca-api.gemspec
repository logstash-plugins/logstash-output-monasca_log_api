Gem::Specification.new do |s|
  s.name = 'logstash-output-monasca-api'
  s.version = "0.1"
  s.licenses = ["Apache License (2.0)"]
  s.summary = "This gem is a logstash output plugin to connect via http to monasca-log-api."
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Fujitsu EST"]
  s.email = "kamil.choroba@est.fujitsu.com"
  s.require_paths = ["lib"]

  # Files
  s.files = `git ls-files`.split($\)
  
  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", ">= 1.4.0", "< 2.0.0"
  s.add_runtime_dependency "logstash-codec-plain"
  s.add_development_dependency "logstash-devutils"
end
