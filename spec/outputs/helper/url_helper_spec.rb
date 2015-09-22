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

describe LogStash::Outputs::Helper::UrlHelper do

  describe ".generate_url" do
    it "generates a URI::HTTP object" do
      expect(LogStash::Outputs::Helper::UrlHelper.generate_url('http://192.168.10.5:8080', '/v2.0')).to be_a URI::HTTP
    end

    it "should match a http url" do
      expect(LogStash::Outputs::Helper::UrlHelper.generate_url('http://192.168.10.5:8080', '/v2.0').to_s).to eq('http://192.168.10.5:8080/v2.0')
      expect(LogStash::Outputs::Helper::UrlHelper.generate_url('http://est.fujitsu:40', nil).to_s).to eq('http://est.fujitsu:40')
      expect(LogStash::Outputs::Helper::UrlHelper.generate_url('http://est.fujitsu:80', nil).to_s).to eq('http://est.fujitsu')
      expect(LogStash::Outputs::Helper::UrlHelper.generate_url('https://192.168.10.5:8080', '/v2.0').to_s).to eq('https://192.168.10.5:8080/v2.0')
    end
  end

end
