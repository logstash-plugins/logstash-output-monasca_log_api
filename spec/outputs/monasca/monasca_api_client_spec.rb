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

describe LogStash::Outputs::Monasca::MonascaLogApiClient do

  let (:auth_hash) { "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"domain\":{\"id\":\"1051bd27b9394120b26d8b08847325c0\"},\"name\":\"csi-operator\",\"password\":\"password\"}}},\"scope\":{\"project\":{\"domain\":{\"id\":\"1051bd27b9394120b26d8b08847325c0\"},\"name\":\"csi\"}}}}" }

  let (:ok_response) { stub_response(201, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"token\":{\"methods\":[\"password\"],\"roles\":[{\"id\":\"9fe2ff9ee4384b1894a90878d3e92bab\",\"name\":\"_member_\"},{\"id\":\"4e9ef1ffe73446c6b02f8fce0585c307\",\"name\":\"monasca-user\"}],\"expires_at\":\"2015-05-26T08:55:36.774122Z\",\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"1051bd27b9394120b26d8b08847325c0\",\"name\":\"mini-mon\"},\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"06ecc9869b8e4846b2fce3e5759ba4af\",\"name\":\"mini-mon\"},\"audit_ids\":[\"ORap7R56S2S-p6tFVeMkpg\"],\"issued_at\":\"2015-05-26T07:55:36.774146Z\"}}") }

  let (:failed_response) { stub_response(401, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"error\": {\"message\": \"Could not find project: f8cdafb7dce94444ad781a53ddaff693 (Disable debug mode to suppress these details.)\", \"code\": 401, \"title\": \"Unauthorized\"}}") }

  let (:data) { LogStash::Event.new({'message' => '2015-08-13 08:36:59,316 INFO monasca_notification.main Received signal 17, beginning graceful shutdown.',
                                      '@version' => '1',
                                      '@timestamp' => '2015-08-13T08:37:00.287Z',
                                      'type' => 'notification',
                                      'service' => 'notification',
                                      'host' => 'monasca',
                                      'path' => '/var/log/monasca/notification/notification.log'}) }

  let (:token) { LogStash::Outputs::Keystone::Token.new('abc', DateTime.now + Rational(5, 1440)) }

  let (:dimensions) { { 'hostname' => 'monasca' } }

  context 'when initializing' do
    it 'then it should register without exceptions' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient.new('hostname:8080')}.to_not raise_error
    end

    it "returns a failure if arguments are missing" do
      # noinspection RubyArgCount
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient.new}.to raise_exception(ArgumentError)
    end
  end

  context 'when sending events' do
  	it 'with dimensions then it should request monasca' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(data, :x_auth_token => token, :content_type => 'application/json', :x_dimensions => dimensions)
      monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient.new('hostname:8080')
      monasca_log_api_client.send_event(nil, data, token, dimensions)
  	end

  	it 'without dimensions then it should request monasca' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(data, :x_auth_token => token, :content_type => 'application/json')
      monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient.new('hostname:8080')
      monasca_log_api_client.send_event(nil, data, token, nil)
    end

    it 'with application_type then it should request monasca with that value' do
      app_type = 'someapp'
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(data, :x_auth_token => token, :content_type => 'application/json', :x_application_type => app_type)
      monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient.new('hostname:8080')
      monasca_log_api_client.send_event(nil, data, token, nil, app_type)
    end
  end

  context 'when sending events failes' do
  	it 'then it should be rescued and a warn log printed' do
  	  expect_any_instance_of(Cabin::Channel).to receive(:warn)
      monasca_log_api_client = LogStash::Outputs::Monasca::MonascaLogApiClient.new('hostname:8080')
      allow(monasca_log_api_client).to receive(:request).and_raise('an_error')
      monasca_log_api_client.send_event(nil, data, token, dimensions)
  	end
  end

end
