# Copyright 2016 FUJITSU LIMITED
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# encoding: utf-8

require 'logstash/outputs/base'
require 'logstash/namespace'
require 'logstash/codecs/base'
require 'vine'
require 'thread'

# relative requirements
require_relative 'monasca/monasca_log_api_client'
require_relative 'keystone/keystone_client'
require_relative 'keystone/token'

# This Logstash Output plugin, sends events to monasca-api.
# It authenticates against keystone and gets a token.
# The token is used to authenticate against the monasca-api and send log events.
class LogStash::Outputs::MonascaLogApi < LogStash::Outputs::Base
  config_name 'monasca_log_api'

  # monasca-log-api configuration
  config :monasca_log_api_url, :validate => :string, :required => true
  config :monasca_log_api_insecure, :validate => :boolean, :required => false,
    :default => false

  # keystone configuration
  config :keystone_api_url, :validate => :string, :required => true
  config :keystone_api_insecure, :validate => :boolean, :required => false,
    :default => false
  config :project_name, :validate => :string, :required => true
  config :username, :validate => :string, :required => true
  config :password, :validate => :string, :required => true
  config :user_domain_name, :validate => :string, :required => true
  config :project_domain_name, :validate => :string, :required => true

  # global dimensions
  config :dimensions, :validate => :array, :required => false

  config :num_of_logs, :validate => :number, :default => 125
  config :elapsed_time_sec, :validate => :number, :default => 30
  config :delay, :validate => :number, :default => 10
  config :max_data_size_kb, :validate => :number, :default => 5120

  attr_accessor :time_thread, :start_time, :logs

  default :codec, 'json'

  JSON_LOGS = 'logs'
  JSON_DIMS = 'dimensions'

  public
  def register
    check_config
    @mutex = Mutex.new
    @logger.info('Registering keystone user',
      :username => username, :project_name => project_name)
    @monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient
      .new monasca_log_api_url, monasca_log_api_insecure
    @logs = Hash.new
    @start_time = nil
    init_token
    initialize_logs_object
    start_time_check
  end

  def multi_receive(events)
    @logger.debug("Retrieving #{events.size} events")
    events.each do |event|
      encode(event)
    end
  end

  def close
    stop_time_check
  end

  private

  def init_token
    token = LogStash::Outputs::Keystone::Token.instance
    token.set_keystone_client(keystone_api_url, keystone_api_insecure)
    check_token
  end

  def encode(event)
    log = generate_log_from_event(event)
    log_bytesize = bytesize_of(log)
    logs_bytesize = bytesize_of(@logs)

    # if new log would exceed the bytesize then send logs without the new log
    if @logs[JSON_LOGS] and (logs_bytesize + log_bytesize) > max_data_size_kb
      @logger.debug('bytesize reached. Sending logs')
      @mutex.synchronize do
        send_logs
        add_log log
      end
      return

    # if the new log would reach the maximum bytesize or the maximum allowed
    # number of sendable logs is reached
    elsif @logs[JSON_LOGS] and (@logs[JSON_LOGS].size + 1 >= num_of_logs)
      @logger.debug('bytesize or maximum number of logs reached. Sending logs')
      @mutex.synchronize do
        add_log log
        send_logs
      end
      return

    # still free space to collect logs
    else
      @mutex.synchronize do
        add_log log
      end
      return
    end
  end

  def generate_log_from_event(event)
    message = event.to_hash['message']
    path = event.to_hash['path']
    local_dims = JSON.parse(event.to_hash['dimensions'].to_s) if
      event.to_hash['dimensions']
    type = event.to_hash['type'] if event.to_hash['type']

    log = { 'message' => message, 'dimensions' => { 'path' => path }}
    log[JSON_DIMS]['type'] = type if type
    if local_dims
      begin
        JSON.parse(local_dims[0])
        local_dims.each { |dim|
          parsed_dim = JSON.parse(dim)
          log[JSON_DIMS][parsed_dim[0].strip] = parsed_dim[1].strip
        }
      rescue
        log[JSON_DIMS][local_dims[0].strip] = local_dims[1].strip
      end
    end
    log
  end

  def initialize_logs_object
    if @logs.empty?
      global_dims = {}
      dimensions.each { |dim|
        global_dims[dim.split(':')[0].strip] = dim.split(':')[1].strip
        } if dimensions
      @logs = {}
      @logs[JSON_DIMS] = global_dims unless global_dims.empty?
      @logs[JSON_LOGS] = []
    end
  end

  def check_token
    token = LogStash::Outputs::Keystone::Token.instance
    token.request_new_token(
      username, user_domain_name, password,
      project_name, project_domain_name) unless token.valid?
  end

  def start_time_check
    @time_thread = Thread.new do

      loop do
        unless @start_time.nil?

          if @logs[JSON_LOGS] and (@logs[JSON_LOGS].size > 0) and
            ((Time.now - @start_time) >= elapsed_time_sec)
            @logger.debug('Time elapsed. Sending logs')
            @mutex.synchronize do
              send_logs
            end
          end

        end
        sleep delay
      end
    end
  end

  def stop_time_check
    @time_thread.kill() if @time_thread
    @logger.info('Stopped time_check thread')
  end

  def bytesize_of(entry)
    entry.to_json.bytesize / 1024.0
  end

  def send_logs
    if @logs[JSON_LOGS] && !@logs[JSON_LOGS].empty?
      check_token
      token = LogStash::Outputs::Keystone::Token.instance
      @logger.debug("Sending #{@logs[JSON_LOGS].size} logs")
      retry_tries = 5
      begin
        tries ||= retry_tries
        @monasca_log_api_client.send_logs(@logs, token.id)
      rescue LogStash::Outputs::Monasca::MonascaLogApiClient::InvalidTokenError => e
        tries -= 1
        if tries > 0
          @logger.info("Unauthorized: #{e}. Requesting new token.")
          token.request_new_token(
            username, user_domain_name, password,
            project_name, project_domain_name
          )
          retry
        else
          @logger.error("Unauthorized: #{e}. Requesting new token failed "\
                        "after #{retry_tries} retries.")
        end
      rescue => e
        @logger.error('Sending event to monasca-log-api threw exception',
                      :exceptionew => e)
      end
      @logs.clear
      initialize_logs_object
    end
  end

  def add_log(log)
    @logs[JSON_LOGS].push(log)
    if @logs[JSON_LOGS].size == 1
      @start_time = Time.now
    end
  end

  def check_config
    bad_val = []
    bad_val << 'num_of_logs' if num_of_logs <= 0
    bad_val << 'elapsed_time_sec' if elapsed_time_sec <= 0
    bad_val << 'delay' if delay <= 0
    bad_val << 'max_data_size_kb' if max_data_size_kb <= 0
    unless bad_val.empty?
      err = "Value of #{bad_val.join(', ')} need to be bigger than 0"
      raise LogStash::ConfigurationError, err
    end
  end
end
