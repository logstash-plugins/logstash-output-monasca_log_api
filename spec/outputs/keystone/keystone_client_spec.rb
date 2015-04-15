require_relative '../spec_helper'

describe KeystoneClient do

  before :each do
    @user = double("User")
  end

  describe "#new" do
    it "takes two parameters and returns a KeystoneClient object" do
      KeystoneClient.new('http://localhost', 5000, @user).should be_an_instance_of KeystoneClient
    end
  end

end