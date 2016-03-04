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

require 'rest-client'
require 'logger'
require 'singleton'

# relative requirements
require_relative '../helper/url_helper'

# This class creates a connection to monasca-log-api
module LogStash::Outputs
  module Monasca
    class MonascaLogApiClient

      SUPPORTED_API_VERSION = %w(3.0)

      def initialize(host, version)
        @logger = Cabin::Channel.get(LogStash)
        rest_client_url = LogStash::Outputs::Helper::UrlHelper
          .generate_url(host, '/' + check_version(version)).to_s
        @rest_client = RestClient::Resource.new(rest_client_url)
      end

      def send_logs(logs, auth_token)
        begin
          post_header = {
              'X-Auth-Token' => auth_token,
              'Content-Type' => 'application/json',
          }
          request(logs.to_json, post_header)
        rescue => e
          @logger.warn('Sending event to monasca-log-api threw exception',
            :exceptionew => e)
        end
      end

      private

      def request(body, header)
        @logger.debug('Sending data to ', :url => @rest_client.url)
        @rest_client['logs'].post(body, header)
      end

      def check_version(version)
        tmp_version = version.sub('v','')

        unless SUPPORTED_API_VERSION.include? tmp_version
          raise "#{tmp_version} is not supported, "\
            "supported versions are #{SUPPORTED_API_VERSION}"
        end

        version
      end

    end
  end
end
