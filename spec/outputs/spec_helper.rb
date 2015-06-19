require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/spec/'
end

require_relative '../../lib/logstash/outputs/monasca_api'
require_relative '../../lib/logstash/outputs/keystone/keystone_client'
require_relative '../../lib/logstash/outputs/keystone/token'
require_relative '../../lib/logstash/outputs/monasca/monasca_api_client'
require_relative '../../lib/logstash/outputs/helper/url_helper'

require 'yaml'
require 'rest-client'
