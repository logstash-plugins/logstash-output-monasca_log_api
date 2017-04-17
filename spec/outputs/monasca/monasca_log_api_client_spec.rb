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
require 'webmock/rspec'

describe LogStash::Outputs::Monasca::MonascaLogApiClient do

  let (:monasca_log_api_url) { 'http://monasca-log-api:5607/v3.0' }
  let (:monasca_log_api_url_https) { 'https://monasca-log-api:5607/v3.0' }
  let (:monasca_log_api_url_post) { monasca_log_api_url + "/logs" }
  let (:token) { "f8cdafb7dce94444ad781a53ddaff693" }
  let (:cross_tenant) { "396ffadd35a187da44449ecd7bfadc8f" }
  let (:monasca_log_api_url_post_with_tenant) { monasca_log_api_url_post +
    "?tenant_id=" + cross_tenant}
  let (:logs) {
    {
      "dimensions" =>
        { "hostname" => "monasca",
          "ip" => "192.168.10.4"
        },
      "logs" =>
        [
          {
            "message" => "x-image-meta-min_disk: 0",
            "dimensions" =>
              {
                "path" => "/var/log/monasca/log-api/info.log",
                "service" => "monasca-log-api",
                "language" => "python"
              }
          }
        ]
    }
  }

  let (:header) { header = { 'X-Auth-Token' => token,
    'Content-Type' => 'application/json' } }

  context 'when initializing' do
    it 'then it should register without exceptions' do
      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url)}.to_not raise_error

      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url, false)}.to_not raise_error

      expect {LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url, true)}.to_not raise_error
    end
  end

  context 'when requesting to monasca-log-api' do
    it 'sends x-auth-token and content-type in header, logs in body' do
      expect_any_instance_of(Cabin::Channel).to_not receive(:error)

      stub_request(:post, monasca_log_api_url_post)
        .with(:headers => {
          'Accept'=>'*/*',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby',
          'X-Auth-Token'=>'f8cdafb7dce94444ad781a53ddaff693'})
        .to_return(:status => 204)

      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url)

      client.send_logs(logs, token, nil)
    end
  end

  context 'when requesting to monasca-log-api with cross_tenant' do
    it 'sends x-auth-token and content-type in header, logs in body,'\
        ' and tenant_id in query parameter' do
      expect_any_instance_of(Cabin::Channel).to_not receive(:error)

      stub_request(:post, monasca_log_api_url_post_with_tenant)
        .with(:headers => {
          'Accept'=>'*/*',
          'Content-Type'=>'application/json',
          'User-Agent'=>'Ruby',
          'X-Auth-Token'=>'f8cdafb7dce94444ad781a53ddaff693'})
        .to_return(:status => 204)

      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url)

      client.send_logs(logs, token, cross_tenant)
    end
  end

  context 'when using https' do
    it 'should change use_ssl property' do
      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url_https)
      http = client.instance_variable_get(:@http)
      expect(http.use_ssl?).to be true
      expect(http.verify_mode).to eq(nil)
    end

    it 'in case of insecure mode it should change verify_mode property' do
      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url_https, true)
      http = client.instance_variable_get(:@http)
      expect(http.use_ssl?).to be true
      expect(http.verify_mode).to eq(OpenSSL::SSL::VERIFY_NONE)
    end
  end

  context 'when request failed' do
    it 'logs a failure' do
      expect_any_instance_of(Cabin::Channel).to receive(:error)

      stub_request(:post, monasca_log_api_url_post)
        .with(:headers =>
        {
          'Accept' => '*/*',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Auth-Token' => 'f8cdafb7dce94444ad781a53ddaff693'
        })
        .to_return(:status => 410)

      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url)

      client.send_logs(logs, token, nil)
    end
  end

  context 'when request failed with 401' do
    it 'logs a warning and throw an exception' do
      expect_any_instance_of(Cabin::Channel).to receive(:warn)

      stub_request(:post, monasca_log_api_url_post)
        .with(:headers =>
        {
          'Accept' => '*/*',
          'Content-Type' => 'application/json',
          'User-Agent' => 'Ruby',
          'X-Auth-Token' => 'f8cdafb7dce94444ad781a53ddaff693'
        })
        .to_return(:status => 401)

      client = LogStash::Outputs::Monasca::MonascaLogApiClient
        .new(monasca_log_api_url)

      expect { client.send_logs(logs, token, nil) }.to raise_error(
        LogStash::Outputs::Monasca::MonascaLogApiClient::InvalidTokenError
      )
    end
  end
end
