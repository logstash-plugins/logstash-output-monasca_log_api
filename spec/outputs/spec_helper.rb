# Copyright 2016 FUJITSU LIMITED
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# encoding: utf-8
require 'yaml'

require 'simplecov'
require 'simplecov-rcov'
require 'rspec_junit_formatter'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start do
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/spec/'
end

require_relative '../../lib/logstash/outputs/monasca_log_api'
require_relative '../../lib/logstash/outputs/keystone/keystone_client'
require_relative '../../lib/logstash/outputs/keystone/token'
require_relative '../../lib/logstash/outputs/monasca/monasca_log_api_client'
