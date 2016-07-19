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

require 'logstash/environment'
require 'logger'
require 'json'
require 'net/http'

require_relative './token'

# This class connects to keystone and authenticates an user.
# If successful authenticated, the class returns a token object
module LogStash::Outputs
  module Keystone
    class KeystoneClient

      @client = nil

      def initialize(url, insecure=false)
        @logger = Cabin::Channel.get(LogStash)
        @uri = URI.parse(url)
        @http = Net::HTTP.new(@uri.host, @uri.port)
        if @uri.scheme == 'https'
          @http.use_ssl = true
          @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if insecure
        end
      end

      def authenticate(username, user_domain_name, password, project_name, project_domain_name)
        auth_hash = generate_hash(username, user_domain_name, password, project_name, project_domain_name)
        post_header = {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json',
          }
        response = request('/auth/tokens', post_header, auth_hash)
        handle_response(response)
      end

      private

      def request(path, header, body)
        @logger.debug('Sending authentication to ', :url => @uri.to_s)
        post_request = Net::HTTP::Post.new(@uri.request_uri + path, header)
        post_request.body = body
        @http.request(post_request)
      end

      def generate_hash(username, user_domain_name, password, project_name, project_domain_name)
        {
          "auth"=>{
            "identity"=>{
              "methods"=>["password"],
              "password"=>{
                "user"=>{
                  "domain"=>{"name"=>user_domain_name},
                  "name"=>username,
                  "password"=>password
                }
              }
            },
            "scope"=>{
              "project"=>{
                "domain"=>{"name"=>project_domain_name},
                "name"=>project_name
              }
            }
          }
        }.to_json
      end

      def handle_response(response)
        case response
        when Net::HTTPCreated
          expires_at = DateTime.parse(
            JSON.parse(response.body)["token"]["expires_at"])

          @logger.debug("Authentication succeed: code=#{response.code}, "\
            "auth-token=#{response['X-Subject-Token']}, "\
            "expires_at=#{expires_at.to_time}")

          {:token => response['X-Subject-Token'],
            :expires_at => expires_at}
        else
          @logger.info("Authentication failed. Response=#{response}")
        end
      end

    end
  end
end
