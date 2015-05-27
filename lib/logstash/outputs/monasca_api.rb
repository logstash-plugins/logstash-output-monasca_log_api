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

  config :dimensions, :validate => :string, :default => nil

  attr_accessor :token

  public
  def register
    @keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new keystone_host, keystone_port
    @monasca_api_client = LogStash::Outputs::Monasca::MonascaApiClient.new monasca_host, monasca_port
    @token = get_token
  end # def register

  def receive(log)
    return unless output?(log)
    check_token
    send_log(log, @token.id, dimensions)
  end # def receive

  private
  def check_token
    now = DateTime.now + Rational(1, 1440)
    if now >= @token.expire_at
      @token = get_token
      @logger.debug("token expired. New token requested")
    end
  end

  def send_log(log, token_id, dimensions)
    @monasca_api_client.send_log(log, token_id, dimensions) if log and token_id
  end

  def get_token
    @keystone_client.authenticate(project_id, user_id, password)
  end
end # class LogStash::Outputs::Example