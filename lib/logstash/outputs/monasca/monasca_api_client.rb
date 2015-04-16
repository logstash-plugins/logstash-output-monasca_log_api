require 'rest-client'

# relative requirements
require_relative '../helper/url_helper'

# This class creates a connection to monasca-api
module LogStash::Outputs
  module Monasca
    class MonascaApiClient
      
      def initialize host, port
        @rest_client = RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, port, '/v2.0').to_s)
      end
    
      # Send log events to monasca-api, requires token
      def send_log(event, token)
        @rest_client['log']['single'].post(event.to_s, :x_auth_token => token, :content_type => 'application/json')
      end
    
    end
  end
end