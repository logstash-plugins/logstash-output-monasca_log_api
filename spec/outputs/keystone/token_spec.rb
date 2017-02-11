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

require_relative '../spec_helper'

describe LogStash::Outputs::Keystone::Token do

  describe "when initializing" do
    it "should be a singleton" do
      expect{LogStash::Outputs::Keystone::Token.new}
        .to raise_exception(NoMethodError)
    end

    it "should always return the same object" do
      token = LogStash::Outputs::Keystone::Token.instance
      another_token = token = LogStash::Outputs::Keystone::Token.instance
      expect(token).to eq(another_token)
    end
  end

  describe "when changing properties" do
    it "should change for each instance" do
      token = LogStash::Outputs::Keystone::Token.instance
      another_token = token = LogStash::Outputs::Keystone::Token.instance
      another_token.set_token(1, 2)
      expect(token).to eq(another_token)
    end
  end

end