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

require 'logstash/environment'
require 'logger'

require_relative '../helper/url_helper'
require_relative './token'

# This class connects to keystone and authenticates an user.
# If successful authenticated, the class returns a token object
module LogStash::Outputs
  module Keystone
    class KeystoneClient

      @client = nil

      def initialize(host)
        @logger = Cabin::Channel.get(LogStash)
        @client = get_client(host, '/v3/auth/tokens')
      end

      def authenticate(domain_id, username, password, project_name)
        auth_hash = generate_hash(domain_id, username, password, project_name)
        response = request(auth_hash)
        handle_response(response)
      end

      private

      def request(auth_hash)
        @client.post(auth_hash, :content_type => 'application/json', :accept => 'application/json')
      end

      def get_client(host, path)
        RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, path).to_s)
      end

      def generate_hash(domain_id, username, password, project_name)
        "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"id\":\"#{domain_id}\"},\"name\":\"#{username}\",\"password\":\"#{password}\"}}},\"scope\":{\"project\":{\"domain\":{\"id\":\"#{domain_id}\"},\"name\":\"#{project_name}\"}}}}"
      end

      def handle_response(response)     
        case response.code
        when 201
          expires_at = DateTime.parse(JSON.parse(response.body)["token"]["expires_at"])
          @logger.debug("Authentication succeed: code=#{response.code}, auth-token=#{response.headers[:x_subject_token]}, expires_at=#{expires_at.to_time}")
          Token.new(response.headers[:x_subject_token], expires_at)    
        else
          @logger.info("Authentication failed. Response=#{response}")
        end
      end

    end
  end
end
