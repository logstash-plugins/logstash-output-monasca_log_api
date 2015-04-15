require_relative '../spec_helper'

describe UrlHelper do

  describe ".generate_url" do
    it "generates a URI::HTTP object" do
      UrlHelper.generate_url('192.168.10.5', 8080, '/v2.0').should be_an_instance_of URI::HTTP
    end

    it "should match a http url" do
      UrlHelper.generate_url('192.168.10.5', 8080, '/v2.0').to_s.eql?('http://192.168.10.5:8080/v2.0').should be_true
    end
  end

end