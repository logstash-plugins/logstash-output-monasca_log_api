require_relative '../spec_helper'

describe LogStash::Outputs::Keystone::Token do

  describe "#new" do
    it "takes two parameters and returns a Token object" do
      token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.now)
      token.should be_an_instance_of LogStash::Outputs::Keystone::Token
    end    
  end

  describe "#==" do
    it "should equal to another token instance" do
      token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-26T08:55:36.774122Z"))
      second_token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-26T08:55:36.774122Z"))
      third_token = LogStash::Outputs::Keystone::Token.new('token-id', DateTime.parse("2015-05-30T08:55:36.774122Z"))

      token.should == second_token
      third_token.should_not == second_token
    end
  end
end