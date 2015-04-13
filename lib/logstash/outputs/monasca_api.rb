# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"

# An example output that does nothing.
class LogStash::Outputs::MonascaApi < LogStash::Outputs::Base
  config_name "monasca_api"

  public
  def register
  end # def register

  public
  def receive(event)
    $stdout.write(event)
    return "Event received"
  end # def event
end # class LogStash::Outputs::Example