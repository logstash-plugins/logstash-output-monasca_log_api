@files=[]

task :default do
  system("rake -T")
end

desc "Build project"
task :build do
  system("bundle install")
end

desc "Run tests"
task :test do
  system("bundle exec rspec")
end

require "logstash/devutils/rake"
