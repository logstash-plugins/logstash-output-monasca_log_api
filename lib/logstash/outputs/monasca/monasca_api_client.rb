require 'rest-client'
require 'logger'

# relative requirements
require_relative '../helper/url_helper'

# This class creates a connection to monasca-api
module LogStash::Outputs
  module Monasca
    class MonascaApiClient
      
      def initialize host, port
        @logger = Cabin::Channel.get(LogStash)
        @rest_client = RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, port, '/v2.0').to_s)
      end
    
      # Send log events to monasca-api, requires token
      def send_log(event, token, dimensions)
        begin
          response = request(event, token, dimensions)
          handle_response(response)
        rescue => e
          handle_error(e)
        end
      end

      private

      def request(event, token, dimensions)
        if dimensions
          @rest_client['log']['single'].post(
            event.to_s, 
            :x_auth_token => token, 
            :content_type => 'application/json', 
            :x_dimensions => dimensions
          )
        else
          @rest_client['log']['single'].post(
            event.to_s, 
            :x_auth_token => token, 
            :content_type => 'application/json'
          )
        end
      end

      def handle_error(response)
        @logger.error("Failed to send event to monasca-api, response=#{response}")
        false
      end

      def handle_response(response)
        case response.code
        when 204
          @logger.debug("Successfully send event to monasca-api")
          true
        else
          @logger.error("Failed to send event to monasca-api, body=#{response.body}")
          false
        end
      end
    
    end
  end
end