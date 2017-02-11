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

require 'logger'
require 'json'
require 'net/http'

# This class creates a connection to monasca-log-api
module LogStash::Outputs
  module Monasca
    class MonascaLogApiClient

      def initialize(url, insecure = false)
        @logger = Cabin::Channel.get(LogStash)
        @uri = URI.parse(url)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        if @uri.scheme == 'https'
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if insecure
        end
      end

      def send_logs(logs, auth_token)
        post_header = {
          'X-Auth-Token' => auth_token,
          'Content-Type' => 'application/json',
        }
        response = request('/logs', post_header, logs.to_json)
        handle_response(response)
      end

      private

      def request(path, header, body)
        @logger.debug('Sending data to ', :url => @uri.to_s)
        post_request = Net::HTTP::Post.new(@uri.request_uri + path, header)
        post_request.body = body
        @http.request(post_request)
      end

      class InvalidTokenError < StandardError; end

      def handle_response(response)
        case response
        when Net::HTTPNoContent
          @logger.debug('Successfully sent logs')
        when Net::HTTPUnauthorized # HTTP code: 401
          @logger.warn("Invalid token. Response=#{response}")
          raise InvalidTokenError, "Invalid token. Response=#{response}"
        else
          # TODO: Handle logs which could not be sent
          @logger.error("Failed to send logs. Response=#{response}")
        end
      end
    end
  end
end
