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

module LogStash::Outputs
  module Keystone
    class Token
      attr_accessor :id, :expire_at
      def initialize id, expire_at
        @id = id
        @expire_at = expire_at
      end

      def ==(another_token)
        self.id == another_token.id && self.expire_at == another_token.expire_at
      end
    end
  end
end