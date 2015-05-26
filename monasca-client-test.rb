require 'rest-client'
require 'rest-client'
require 'json'
require 'date'

class TestClient

  @client = nil

  def initialize(host, port, path)
    @client = get_client(host, port, path)
  end

  def send_log(event, token)
    begin
      resp = @client['log']['single'].post(event.to_s, :x_auth_token => token, :content_type => 'application/json')
      puts resp.headers
      puts resp.code
    rescue => e
      puts e
    end
  end

  private

  def get_client(host, port, path)
    RestClient::Resource.new(URI::HTTP.new('http', nil, host, port, nil, path, nil, nil, nil).to_s)
  end

end

t = TestClient.new('192.168.10.4', 8080, '/v2.0')
t.send_log('log-message', 'xxabadcf984cf7401e88579d393317b0d9')