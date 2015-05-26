require_relative 'spec_helper'

describe "outputs/monasca_api" do

  before :each do
    @monasca_api = LogStash::Plugin.lookup("output", "monasca_api").new("monasca_host" => "192.168.10.4", "monasca_port" => 8080, "keystone_host" => "192.168.10.5", "keystone_port" => 5000, "project_id" => "abadcf984cf7401e88579d393317b0d9", "user_id" => "abadcf984cf7401e88579d393317b0d9", "password" => "password")  
  end

  describe "#register" do
    #it "should register" do
  	#  @monasca_api.stub(:get_token).and_return(LogStash::Outputs::Keystone::Token.new(nil, nil))
    #  expect{@monasca_api.register}.to_not raise_error
    #end

    #it "should fail to register if authentication failed" do
    #  @monasca_api.stub(:get_token).and_raise(LogStash::PluginLoadingError.new)
    #  expect{@monasca_api.register}.to raise_error
    #end
  end

end