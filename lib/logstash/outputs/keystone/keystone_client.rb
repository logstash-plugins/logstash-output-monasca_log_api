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

      def authenticate(domain_id, username, password, project_name)
        auth_hash = generate_hash(domain_id, username, password, project_name)
        response = request(auth_hash)
        handle_response(response)
      end

      private

      def request(auth_hash)
        @client.post(auth_hash, :content_type => 'application/json', :accept => 'application/json')
      end

      def get_client(host, port, path)
        RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, port, path).to_s)
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
        end
      end

    end
  end
end
