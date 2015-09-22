=begin
Copyright 2015 FUJITSU LIMITED

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied. See the License for the specific language governing permissions and limitations under
the License.
=end

# encoding: utf-8

require 'logstash/outputs/base'
require 'logstash/namespace'
require 'vine'

# relative requirements
require_relative 'monasca/monasca_log_api_client'
require_relative 'keystone/keystone_client'

# This Logstash Output plugin, sends events to monasca-api.
# It authenticates against keystone and gets a token.
# The token is used to authenticate against the monasca-api and send log events.
class LogStash::Outputs::MonascaLogApi < LogStash::Outputs::Base
  config_name 'monasca_log_api'

  # monasca-api host and port configuration
  config :monasca_log_api, :validate => :string, :required => true

  # keystone host and port configuration
  config :keystone_api, :validate => :string, :required => true
  # keystone user configuration
  config :project_name, :validate => :string, :required => true
  config :username, :validate => :string, :required => true
  config :password, :validate => :string, :required => true
  config :domain_id, :validate => :string, :required => true

  config :dimensions, :validate => :string, :default => nil
  config :application_type_key, :validate => :string, :default => 'type'

  attr_accessor :token

  default :codec, 'json'

  public
  def register
    @keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new keystone_api
    @monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient.new monasca_log_api
    @token = get_token

    @logger.info('Registering keystone user', :username => @username, :project_name => @project_name)

    @codec.on_event do |event, data|
      check_token
      send_event(event, data, dimensions)
    end

  end # def register

  def receive(event)
    return unless output?(event)
    if event == LogStash::SHUTDOWN
      finished
      return
    end
    @codec.encode(event)
  end # def receive

  def finished
    if @shutdown_queue
      @logger.info('Sending shutdown event to agent queue', :plugin => self.class.config_name)
      @shutdown_queue << self
    end
    if @plugin_state != :finished
      @logger.info('Plugin is finished', :plugin => self.class.config_name)
      @plugin_state = :finished
    end
  end

  def shutdown(queue)
    teardown
    @logger.info('Received shutdown signal', :plugin => self.class.config_name)

    @shutdown_queue = queue
    if @plugin_state == :finished
      finished
    else
      @plugin_state = :terminating
    end
  end

  private
  def check_token
    now = DateTime.now + Rational(1, 1440)
    if now >= @token.expire_at
      @token = get_token
      @logger.info('Token expired. New token requested')
    end
  end

  def send_event(event, data, dimensions)
    @monasca_log_api_client.send_event(event, data, @token.id, dimensions, get_application_type(event)) if event and @token.id and data
  end

  def get_application_type(event)

    # support for nested.keys.with.lists.0
    if @application_type_key.include? '.'
      split_key = @application_type_key.split('.')
      event_value = event[split_key[0]]
      access_key = split_key.slice(1..-1).join('.')

      app_type = event_value.access(access_key)

    else
      app_type = event[@application_type_key]
    end

    @logger.debug(
        'Retrieved application_type', :application_type => app_type, :application_type_key => @application_type_key
    )
    app_type
  end

  def get_token
    @keystone_client.authenticate(domain_id, username, password, project_name)
  end

end # class LogStash::Outputs::Example
