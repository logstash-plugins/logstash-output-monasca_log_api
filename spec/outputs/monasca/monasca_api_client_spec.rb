require_relative '../spec_helper'

describe MonascaApiClient do

  describe "#new" do
    it "takes two parameters and returns a MonascaApiClient object" do
      MonascaApiClient.new('http://localhost', 5000).should be_an_instance_of MonascaApiClient
    end
  end

end