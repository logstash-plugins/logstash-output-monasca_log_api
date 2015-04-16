require_relative '../spec_helper'

describe LogStash::Outputs::Monasca::MonascaApiClient do

  before :each do
  	@client = LogStash::Outputs::Monasca::MonascaApiClient.new('http://localhost', 5000)
  end

  describe "#new" do
    it "takes two parameters and returns a MonascaApiClient object" do
      @client.should be_an_instance_of LogStash::Outputs::Monasca::MonascaApiClient
    end
  end

end