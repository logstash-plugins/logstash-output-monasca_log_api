require_relative '../spec_helper'

describe LogStash::Outputs::Keystone::KeystoneClient do

  before :each do
    @keystone_client = LogStash::Outputs::Keystone::KeystoneClient.new('hostname', 8080)
  end

  describe "#new" do
    it "takes two parameters and returns a KeystoneClient object" do
      @keystone_client.should be_an_instance_of LogStash::Outputs::Keystone::KeystoneClient
    end

    it "returns a failure if arguments are missing" do
      expect {@keystone_client.authenticate('project_id', 'user_id')}.to raise_exception(ArgumentError)
      expect {@keystone_client.authenticate('project_id')}.to raise_exception(ArgumentError)
    end

  end

  describe "#authenticate" do

    it "authenticates user successfully" do
      
      response = stub_response(201, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"token\":{\"methods\":[\"password\"],\"roles\":[{\"id\":\"9fe2ff9ee4384b1894a90878d3e92bab\",\"name\":\"_member_\"},{\"id\":\"4e9ef1ffe73446c6b02f8fce0585c307\",\"name\":\"monasca-user\"}],\"expires_at\":\"2015-05-26T08:55:36.774122Z\",\"project\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"1051bd27b9394120b26d8b08847325c0\",\"name\":\"mini-mon\"},\"user\":{\"domain\":{\"id\":\"default\",\"name\":\"Default\"},\"id\":\"06ecc9869b8e4846b2fce3e5759ba4af\",\"name\":\"mini-mon\"},\"audit_ids\":[\"ORap7R56S2S-p6tFVeMkpg\"],\"issued_at\":\"2015-05-26T07:55:36.774146Z\"}}")
      @keystone_client.stub(:request).and_return(response)
      @keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'username', 'password', 'project_name').should == LogStash::Outputs::Keystone::Token.new('f8cdafb7dce94444ad781a53ddaff693', DateTime.parse("2015-05-26T08:55:36.774122Z"))
    end

    it "authenticates user with false credentials" do
      
      response = stub_response(401, {:x_subject_token => "f8cdafb7dce94444ad781a53ddaff693"}, "{\"error\": {\"message\": \"Could not find project: f8cdafb7dce94444ad781a53ddaff693 (Disable debug mode to suppress these details.)\", \"code\": 401, \"title\": \"Unauthorized\"}}")
      @keystone_client.stub(:request).and_raise(response)
      expect {@keystone_client.authenticate('1051bd27b9394120b26d8b08847325c0', 'username', 'password', 'project_name')}.to raise_exception
    end
  end

  private

  def stub_response(code, headers, body)
    response = double
    response.stub(:code) { code }
    response.stub(:headers) { headers }
    response.stub(:body) { body }
    response
  end
end