require_relative 'spec_helper'

describe "outputs/monasca_api" do

  before :each do
    @monasca_api = LogStash::Plugin.lookup("output", "monasca_api").new("monasca_host" => "192.168.10.4", "monasca_port" => 8080, "keystone_host" => "192.168.10.5", "keystone_port" => 5000, "project_id" => "abadcf984cf7401e88579d393317b0d9", "user_id" => "abadcf984cf7401e88579d393317b0d9", "password" => "password")  
  end

  describe "#register" do
    it "should register" do
  	  @monasca_api.stub(:get_token).and_return(LogStash::Outputs::Keystone::Token.new(nil, nil))
      expect{@monasca_api.register}.to_not raise_error
    end    
  end

  describe "#check_token" do
    it "should not create a new token if existing is valid" do
      valid_token = LogStash::Outputs::Keystone::Token.new('abc', DateTime.now + Rational(5, 1440))
      new_token = LogStash::Outputs::Keystone::Token.new('def', DateTime.now + Rational(10, 1440))
      @monasca_api.token = valid_token
      @monasca_api.stub(:get_token).and_return(new_token)
      @monasca_api.stub(:send_log).and_return(true)
      @monasca_api.receive('event')
      @monasca_api.token.should == valid_token
    end

    it "should create a new token if existing is expired" do
      invalid_token = LogStash::Outputs::Keystone::Token.new('abc', DateTime.now - Rational(5, 1440))
      new_token = LogStash::Outputs::Keystone::Token.new('def', DateTime.now + Rational(10, 1440))
      @monasca_api.token = invalid_token
      @monasca_api.stub(:get_token).and_return(new_token)
      @monasca_api.stub(:send_log)
      @monasca_api.receive('event')
      @monasca_api.token.should == new_token
    end
  end

end