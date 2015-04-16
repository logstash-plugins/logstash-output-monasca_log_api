require_relative '../spec_helper'

describe LogStash::Outputs::Helper::UrlHelper do

  describe ".generate_url" do
    it "generates a URI::HTTP object" do
      LogStash::Outputs::Helper::UrlHelper.generate_url('192.168.10.5', 8080, '/v2.0').should be_an_instance_of URI::HTTP
    end

    it "should match a http url" do
      LogStash::Outputs::Helper::UrlHelper.generate_url('192.168.10.5', 8080, '/v2.0').to_s.should == 'http://192.168.10.5:8080/v2.0'
      LogStash::Outputs::Helper::UrlHelper.generate_url('est.fujitsu', 40, nil).to_s.should == 'http://est.fujitsu:40'
      LogStash::Outputs::Helper::UrlHelper.generate_url('est.fujitsu', 80, nil).to_s.should == 'http://est.fujitsu'
    end
  end

end