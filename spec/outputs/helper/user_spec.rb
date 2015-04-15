require_relative '../spec_helper'

describe User do

  before :each do
    @user = User.new 'mini-mon', 'admin', 'qweqwe'
  end

  describe "#new" do
    it "takes three parameters and returns a User object" do
      @user.should be_an_instance_of User
    end
  end

  describe "#tenant" do
  	it "returns the tenant name" do
  	  @user.tenant.should match('mini-mon')
  	end
  end

  describe "#user" do
  	it "returns the username" do
  	  @user.username.should match('admin')
  	end
  end

  describe "#password" do
  	it "returns the password" do
  	  @user.password.should match('qweqwe')
  	end
  end

end