require 'uri'

module LogStash::Outputs
  module Helper
    class UrlHelper
      def self.generate_url(host, port, path)
        URI::HTTP.new('http', nil, host, port, nil, path, nil, nil, nil)
      end
    end
  end
end