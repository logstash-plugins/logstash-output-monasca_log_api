# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'

# relative requirements
require_relative 'monasca/monasca_api_client'
require_relative 'keystone/keystone_client'

# This Logstash Output plugin, sends events to monasca-api.
# It authenticates against keystone and gets a token.
# The token is used to authenticate against the monasca-api and send log events.
class LogStash::Outputs::MonascaApi < LogStash::Outputs::Base
  config_name 'monasca_api'

  # monasca-api host and port configuration
  config :monasca_host, :validate => :string, :required => true
  config :monasca_port, :validate => :string, :required => true

  # keystone host and port configuration
  config :keystone_host, :validate => :string, :required => true
  config :keystone_port, :validate => :string, :required => true
  # keystone user configuration
  config :project_id, :validate => :string, :required => true
  config :user_id, :validate => :string, :required => true
  config :password, :validate => :string, :required => true

  public
  def register
    @keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new keystone_host, keystone_port
    token = get_token
    @monasca_api_client = LogStash::Outputs::Monasca::MonascaApiClient.new monasca_host, monasca_port
  end # def register

  def receive(log)
    return unless output?(log)
    begin
      @monasca_api_client.send_log(log, get_token)
    rescue => e
      @logger.error("Failed to send log to monasca-api: #{e.message}")
    end
  end # def receive

  private
  def get_token
    @keystone_client.authenticate(project_id, user_id, password).id
  end
end # class LogStash::Outputs::Example