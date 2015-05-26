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

      def initialize(host, port)
        @logger = Cabin::Channel.get(LogStash)
        @client = get_client(host, port, '/v3/auth/tokens')
      end

      def authenticate(project_id, user_id, password)

        auth_hash = generate_hash(project_id, user_id, password)
        begin
          response = request(auth_hash)
          handle_response(response)
        rescue => e
          handle_error(e)
        end
        
      end

      private

      def request(auth_hash)
        @client.post(auth_hash, :content_type => 'application/json', :accept => 'application/json')
      end

      def get_client(host, port, path)
        RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, port, path).to_s)
      end

      def generate_hash(project_id, user_id, password)
        "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"id\":\"#{user_id}\",\"password\":\"#{password}\"}}},\"scope\":{\"project\":{\"id\":\"#{project_id}\"}}}}"
      end

      def handle_response(response)
        case response.code
        when 201
          expires_at = DateTime.parse(JSON.parse(response.body)["token"]["expires_at"])
          @logger.info("Authentication succeed: code=#{response.code}, auth-token=#{response.headers[:x_subject_token]}, expires_at=#{expires_at.to_time}")
          Token.new(response.headers[:x_subject_token], expires_at)
        else
          @logger.error("Failed to authenticate against keystone: code=#{response.code}")
          Token.new(nil, nil)
        end
      end

      def handle_error(response)
        @logger.error("Failed to authenticate against keystone: response=#{response}")
        Token.new(nil, nil)
      end
         
    end
  end
end