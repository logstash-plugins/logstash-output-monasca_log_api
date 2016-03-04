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

describe LogStash::Outputs::Keystone::KeystoneClient do

  let (:valid_date) { DateTime.now + Rational(1, 1440) }
  let (:token) { "f8cdafb7dce94444ad781a53ddaff693" }
  let (:valid_token) { {:token => token,
    :expires_at => valid_date } }
  let (:domain_id) { "default" }
  let (:username) { "operator" }
  let (:password) { "zPrHGl<IJtn=ux;{&T/nfXh=H" }
  let (:project_name) { "monasca" }
  let (:auth_hash) {
    {
      "auth"=>{
        "identity"=>{
          "methods"=>["password"],
          "password"=>{
            "user"=>{
              "domain"=>{"id"=>domain_id},
              "name"=>username,
              "password"=>password
            }
          }
        },
        "scope"=>{
          "project"=>{
            "domain"=>{"id"=>domain_id},
            "name"=>project_name
          }
        }
      }
    }.to_json
  }

  let (:ok_response) { stub_response(201,
    {:x_subject_token => token},
    {
      "token"=>{
        "methods"=>["password"],
        "roles"=>[
          {
            "id"=>"9fe2ff9ee4384b1894a90878d3e92bab",
            "name"=>"_member_"
          },
          {
            "id"=>"4e9ef1ffe73446c6b02f8fce0585c307",
            "name"=>"monasca-user"
          }
        ],
        "expires_at"=>valid_date.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "project"=>{
          "domain"=>{
            "id"=>"default",
            "name"=>"Default"
          },
          "id"=>"1051bd27b9394120b26d8b08847325c0",
          "name"=>project_name
        },
        "user"=>{
          "domain"=>{
            "id"=>"default",
            "name"=>"Default"
          },
          "id"=>"06ecc9869b8e4846b2fce3e5759ba4af",
          "name"=>username
        },
        "audit_ids"=>["ORap7R56S2S-p6tFVeMkpg"],
        "issued_at"=>"2015-05-26T07:55:36.774146Z"
      }
    }.to_json)
  }

  let (:failed_response) { stub_response(401,
    {:x_subject_token => ""},
    {
      "error"=>{
        "message"=>"Could not find project: f8cdafb7dce94444ad781a53ddaff693 "\
          "(Disable debug mode to suppress these details.)",
        "code"=>401,
        "title"=>"Unauthorized"
      }
    }.to_json)
  }

  context 'when initializing' do
    it 'then it should register without exceptions' do
      expect {LogStash::Outputs::Keystone::KeystoneClient.new('hostname:8080')}
        .to_not raise_error
    end

    it "returns a failure if arguments are missing" do
      expect {LogStash::Outputs::Keystone::KeystoneClient.new}
        .to raise_exception(ArgumentError)
    end
  end

  context 'when authenticates' do
    it 'then it should request to keystone' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .with(auth_hash, :content_type => 'application/json',
          :accept => 'application/json').and_return(ok_response)

      keystone_client = LogStash::Outputs::Keystone::KeystoneClient
        .new('hostname:8080')
      keystone_client.authenticate(domain_id, username, password, project_name)
    end

    it 'then it should return a token' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .and_return(ok_response)
      keystone_client = LogStash::Outputs::Keystone::KeystoneClient
        .new('hostname:8080')
      token = keystone_client
        .authenticate(domain_id, username, password, project_name)
      expect(token["token"]).to eq(valid_token["token"])
      expect(token["expires_at"].to_s).to eq(valid_token["expires_at"].to_s)
    end
  end

  context 'when authentication failed' do
    it 'then it should log an information' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .and_return(failed_response)
      expect_any_instance_of(Cabin::Channel).to receive(:info)

      keystone_client = LogStash::Outputs::Keystone::KeystoneClient
        .new('hostname:8080')
      keystone_client.authenticate(domain_id, username, password, project_name)
    end

    it 'then it should return nil' do
      expect_any_instance_of(RestClient::Resource).to receive(:post)
        .and_return(failed_response)
      expect_any_instance_of(Cabin::Channel).to receive(:info)

      keystone_client = LogStash::Outputs::Keystone::KeystoneClient
        .new('hostname:8080')
      expect(keystone_client
        .authenticate(domain_id, username, password, project_name)).to eq(nil)
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