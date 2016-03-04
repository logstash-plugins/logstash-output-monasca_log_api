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

describe LogStash::Outputs::Monasca::MonascaLogApiClient do

  let (:version) { '3.0' }
  let (:valid_date) { DateTime.now + Rational(1, 1440) }
  let (:token) { LogStash::Outputs::Keystone::Token
    .instance.set_token('abc', valid_date) }
  let (:logs) {  }
  let (:header) { header = { 'X-Auth-Token' => token,
    'Content-Type' => 'application/json' } }

  before(:each) do
    stub_const(
      "LogStash::Outputs::Monasca::MonascaLogApiClient::SUPPORTED_API_VERSION",
      [version])
  end

  context 'when initializing' do
    it 'then it should register without exceptions' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', 'v3.0')}.to_not raise_error
    end
  end

  context 'when requesting to monasca-log-api' do
    it 'sends x-auth-token and content-type in header, logs in body' do
      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', 'v3.0')
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(logs.to_json, header)
      client.send_logs(logs, token)
    end
  end

  context 'when request failed' do
    it 'rescued the exception and logs a failure' do
      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', 'v3.0')
      expect_any_instance_of(Cabin::Channel).to receive(:warn)
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .and_raise(Errno::ECONNREFUSED)
      client.send_logs(logs, token)
    end
  end

  context 'api version checking' do
    it 'should pass for correct version' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', 'v3.0')}.to_not raise_error
    end

    it 'should pass if version does not specify v' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', '3.0')}.to_not raise_error
    end

    it 'should fail for unsupported version' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new('hostname:8080', 'v4.0')}.to raise_exception
    end
  end

end
