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

describe LogStash::Outputs::Keystone::KeystoneClient do

  let (:auth_hash) { "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"id\":\"1051bd27b9394120b26d8b08847325c0\"},\"name\":\"csi-operator\",\"password\":\"password\"}}},\"scope\":{\"project\":{\"domain\":{\"id\":\"1051bd27b9394120b26d8b08847325c0\"},\"name\":\"csi\"}}}}" }

  let (:ok_response) { stub_response(201, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"token\":{\"methods\":[\"password\"],\"roles\":[{\"id\":\"9fe2ff9ee4384b1894a90878d3e92bab\",\"name\":\"_member_\"},{\"id\":\"4e9ef1ffe73446c6b02f8fce0585c307\",\"name\":\"monasca-user\"}],\"expires_at\":\"2015-05-26T08:55:36.774122Z\",\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"1051bd27b9394120b26d8b08847325c0\",\"name\":\"mini-mon\"},\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"06ecc9869b8e4846b2fce3e5759ba4af\",\"name\":\"mini-mon\"},\"audit_ids\":[\"ORap7R56S2S-p6tFVeMkpg\"],\"issued_at\":\"2015-05-26T07:55:36.774146Z\"}}") }

  let (:failed_response) { stub_response(401, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"error\": {\"message\": \"Could not find project: f8cdafb7dce94444ad781a53ddaff693 (Disable debug mode to suppress these details.)\", \"code\": 401, \"title\": \"Unauthorized\"}}") }

  context 'when initializing' do
    it 'then it should register without exceptions' do
      expect {LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')}.to_not raise_error
    end

    it "returns a failure if arguments are missing" do
      expect {LogStash::Outputs::Keystone::KeystoneClient.new}.to raise_exception(ArgumentError)
    end
  end

  context 'when authenticates' do
    it 'then it should request to keystone' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(auth_hash, :content_type => 'application/json', :accept => 'application/json')
      keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')
      allow(keystone_client).to receive(:handle_response).and_return(LogStash::Outputs::Keystone::Token.new('abc', DateTime.now + Rational(5, 1440)))
      keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'csi-operator', 'password', 'csi')
    end

    it 'then it should create a new token' do
      keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')
      allow(keystone_client).to receive(:request).and_return(ok_response)
      expected = LogStash::Outputs::Keystone::Token.new('f8cdafb7dce94444ad781a53ddaff693', DateTime.parse("2015-05-26T08:55:36.774122Z"))
      actual = keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'csi-operator', 'password', 'csi')
      expect(actual).to eq(expected)
    end
  end

  context 'when authentication failed' do
    it 'then it should not create a new token' do
      expect_any_instance_of(Cabin::Channel).to receive(:info)
      keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')
      allow(keystone_client).to receive(:request).and_return(failed_response)
      actual = keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'csi-operator', 'password', 'csi')
      expect(actual).to eq(nil)
    end

    it 'then it should log an information' do
      expect_any_instance_of(Cabin::Channel).to receive(:info)
      keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')
      allow(keystone_client).to receive(:request).and_return(failed_response)
      keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'csi-operator', 'password', 'csi')
    end
  end

  private

  def stub_response(code, headers, body)
    response = double
    allow(response).to receive(:code) { code }
    allow(response).to receive(:headers) { headers }
    allow(response).to receive(:body) { body }
    response
  end
end