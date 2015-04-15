class User
  attr_accessor :tenant, :username, :password
  def initialize tenant, username, password
    @tenant = tenant
    @username = username
    @password = password
  end
end