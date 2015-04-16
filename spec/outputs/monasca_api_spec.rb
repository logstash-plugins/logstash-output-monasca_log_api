require_relative 'spec_helper'

describe "outputs/monasca_api" do

  before :each do
    @monasca_api = LogStash::Plugin.lookup("output", "monasca_api").new("monasca_host" => "192.168.10.4", "monasca_port" => 8080, "keystone_host" => "192.168.10.5", "keystone_port" => 5000, "tenant" => "mini-mon", "username" => "admin", "password" => "password")  
  end

end