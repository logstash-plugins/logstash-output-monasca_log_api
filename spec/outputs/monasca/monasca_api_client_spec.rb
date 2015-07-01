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

describe LogStash::Outputs::Monasca::MonascaApiClient do

  before :each do
  	@monasca_client = LogStash::Outputs::Monasca::MonascaApiClient.new('localhost', 5000)
  end

  describe "#new" do
    
    it "takes two parameters and returns a MonascaApimonasca_client object" do
      @monasca_client.should be_an_instance_of LogStash::Outputs::Monasca::MonascaApiClient
    end

    it "returns a failure if arguments are missing" do
      expect {@monasca_client.send_log('event')}.to raise_exception(ArgumentError)
    end
  end

  describe "#send_log" do
  	it "sends successfully an event to monasca-api" do
  	  response = stub_response(204, nil, nil)

      @monasca_client.stub(:request).and_return(response)
  	  expect {@monasca_client.send_log('event-message', 'abadcf984cf7401e88579d393317b0d9', 'dimensions')}.not_to raise_exception
    end

  	it "failed to connect to monasca-api" do
  	  response = stub_response(404, nil, "Connection refused")

      @monasca_client.stub(:request).and_raise(response)
  	  expect {@monasca_client.send_log('event-message', 'abadcf984cf7401e88579d393317b0d9', 'dimensions')}.to raise_exception
    end

  	it "with false authentication-token" do
  	  response = stub_response(401, nil, "{\"unauthorized\":{\"code\":401,\"message\":\"Authorization failed for user token: xxabadcf984cf7401e88579d393317b0d9 xxabadcf984cf7401e88579d393317b0d9\",\"details\":\"\",\"internal_code\":\"330977495d9aa267\"}}")

      @monasca_client.stub(:request).and_raise(response)
  	  expect {@monasca_client.send_log('event-message', 'bcddcf984cf7401e88579d393317b0d9', 'dimensions')}.to raise_exception
    end
  end

  private

  def stub_response(code, headers, body)
    response = double
    response.stub(:code) { code } if code
    response.stub(:headers) { headers } if headers
    response.stub(:body) { body } if body
    response
  end

end