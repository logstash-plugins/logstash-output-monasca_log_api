require_relative '../helper/url_helper'
require_relative '../helper/user'

# This class creates a connection to keystone
class KeystoneClient
  def initialize host, port, user
    @user = user
  	@keystone_client = RestClient::Resource.new(UrlHelper.generate_url(host, port, '/v2.0').to_s)
  end

  # Authenticate against keystone and get token back
  def get_token
  	json_resp = JSON.parse(authenticate)
  	json_resp['access']['token']['id']
  end

  private
  def get_auth_hash
  	"{\"auth\": {\"tenantName\": \"#{@user.tenant}\", \"passwordCredentials\": {\"username\": \"#{@user.username}\", \"password\": \"#{@user.password}\"}}}"
  end

  def authenticate
    @keystone_client['tokens'].post(get_auth_hash, :content_type => 'application/json', :accept => 'application/json')
  end

end