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

require_relative '../spec_helper'

describe LogStash::Outputs::Keystone::Token do

  describe "#new" do
    it "takes two parameters and returns a Token object" do
      token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.now)
      expect(token).to be_a(LogStash::Outputs::Keystone::Token)
    end    
  end

  describe "#==" do
    it "should equal to another token instance" do
      token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-26T08:55:36.774122Z"))
      second_token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-26T08:55:36.774122Z"))
      third_token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-30T08:55:36.774122Z"))

      expect(token).to eq(second_token)
      expect(third_token).to_not eq(second_token)
    end
  end
end