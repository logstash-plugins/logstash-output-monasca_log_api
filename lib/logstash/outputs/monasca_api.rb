# encoding: utf-8
require 'logstash/outputs/base'
require 'logstash/namespace'

# relative requirements
require_relative 'monasca/monasca_api_client'
require_relative 'keystone/keystone_client'
require_relative 'helper/user'

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
  config :tenant, :validate => :string, :required => true
  config :username, :validate => :string, :required => true
  config :password, :validate => :string, :required => true

  public
  def register
    user = User.new @tenant, @username, @password
  	@monasca_api_client = MonascaApiClient.new monasca_host, monasca_port
    @keystone_client = KeystoneClient.new keystone_host, keystone_port, user
  end # def register

  public
  def receive(event)
    return unless output?(event)
    @monasca_api_client.send_log(event, @keystone_client.get_token)
  end # def receive

end # class LogStash::Outputs::Example