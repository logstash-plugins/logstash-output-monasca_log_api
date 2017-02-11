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

require 'singleton'
require 'logger'
require_relative 'keystone_client'

module LogStash::Outputs
  module Keystone
    class Token
      include Singleton
      attr_accessor :id, :expires_at, :keystone_client

      def request_new_token(username, user_domain_name, password, project_name, project_domain_name)
        token = @keystone_client
          .authenticate(username, user_domain_name, password, project_name, project_domain_name)
        set_token(token[:token], token[:expires_at])
        @logger.info('New token requested')
        @logger.debug("token=#{@id}, expire_at=#{@expires_at}")
      end

      def set_token(id, expires_at)
        @id = id
        @expires_at = expires_at
      end

      def set_keystone_client(keystone_api, insecure)
        @keystone_client = LogStash::Outputs::Keystone::KeystoneClient
          .new(keystone_api, insecure)
      end

      def initialize
        @logger = Cabin::Channel.get(LogStash)
      end

      def valid?
        token_valid = true
        now = DateTime.now + Rational(1, 1440)
        if @id.nil? || now >= @expires_at
          token_valid = false
        end
        token_valid
      end
    end
  end
end
