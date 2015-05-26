require 'rest-client'
require 'rest-client'
require 'json'
require 'date'

class TestClient

  @keystone_client = nil

  def initialize(host, port, path)
    @keystone_client = get_client(host, port, path)
  end

  def authenticate (project_id, user_id, password)

    response = nil

    auth_hash = generate_hash(project_id, user_id, password)

    begin
      response = @keystone_client.post(auth_hash, :content_type => 'application/json', :accept => 'application/json')
      handle_response(response)
    rescue => e
      handle_error e
    end
    
  end

  private

  def get_client(host, port, path)
    RestClient::Resource.new(URI::HTTP.new('http', nil, host, port, nil, path, nil, nil, nil).to_s)
  end

  def generate_hash(project_id, user_id, password)
    "{\"auth\":{\"identity\":{\"methods\":[\"password\"],\"password\":{\"user\":{\"id\":\"#{user_id}\",\"password\":\"#{password}\"}}},\"scope\":{\"project\":{\"id\":\"#{project_id}\"}}}}"
  end

  def handle_response(response)
    case response.code
    when 201
      puts response.body
      d1 = DateTime.parse(JSON.parse(response)["token"]["expires_at"])
      puts "class => #{response.class}, code => #{response.code}, auth-token => #{response.headers[:x_subject_token]}, expires_at => #{d1.to_time}"

      #Token.new(response.headers[:x_subject_token], d1)
    else
      puts "class => #{response.class}, code => #{response.code}, auth-token => #{response.headers[:x_subject_token]}"
    end
  end

  def handle_error(response)
    puts response
    #puts "class => #{response.class}, code => #{response.code}, headers => #{response.headers}, response => #{response}"
  end

end

t = TestClient.new('192.168.10.5', 35357, '/v3/auth/tokens')
t.authenticate('1051bd27b9394120b26d8b08847325c0', '06ecc9869b8e4846b2fce3e5759ba4af', 'password')