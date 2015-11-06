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

      SUPPORTED_API_VERSION = %w(2.0)

      def initialize(host, version)
        @logger = Cabin::Channel.get(LogStash)
        @rest_client_url = LogStash::Outputs::Helper::UrlHelper.generate_url(host, '/' + check_version(version)).to_s
        @rest_client = RestClient::Resource.new(@rest_client_url)
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

        @logger.debug('Sending data to ', :url => @rest_client_url)
        @rest_client['log']['single'].post(data, post_headers)
      end


      def check_version(version)
        tmp_version = version.sub('v','')

        unless SUPPORTED_API_VERSION.include? tmp_version
          raise "#{tmp_version} is not supported, supported versions are #{SUPPORTED_API_VERSION}"
        end

        version
      end

    end
  end
end
