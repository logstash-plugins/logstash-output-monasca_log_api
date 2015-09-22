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

require 'rest-client'
require 'logger'

# relative requirements
require_relative '../helper/url_helper'

# This class creates a connection to monasca-api
module LogStash::Outputs
  module Monasca
    class MonascaLogApiClient

      def initialize(host)
        @logger = Cabin::Channel.get(LogStash)
        @rest_client = RestClient::Resource.new(LogStash::Outputs::Helper::UrlHelper.generate_url(host, '/v2.0').to_s)
      end

      # Send log events to monasca-api, requires token
      def send_event(event, data, token, dimensions, application_type=nil)
        begin
          request(event, data, token, dimensions, application_type)
          @logger.debug("Successfully send event=#{event}, with token=#{token} and dimensions=#{dimensions} to monasca-api")
        rescue => e
          @logger.warn('Sending event to monasca-log-api threw exception', :exceptionew => e)
        end
      end

      private

      def request(event, data, token, dimensions, application_type)
        post_headers = {
            :x_auth_token => token,
            :content_type => 'application/json',
        }
        if dimensions
          post_headers[:x_dimensions] = dimensions
        end

        if application_type
          post_headers[:x_application_type] = application_type
        end
        @rest_client['log']['single'].post(data, post_headers)
      end

    end
  end
end
