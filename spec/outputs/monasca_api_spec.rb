=begin
Copyright 2015 FUJITSU LIMITED

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License
is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied. See the License for the specific language governing permissions and limitations under
the License.
=end

# encoding: utf-8

require_relative 'spec_helper'

describe 'outputs/monasca_log_api' do

  let (:expected_application_type) { 'notification' }

  let (:event) { LogStash::Event.new({'message' => '2015-08-13 08:36:59,316 INFO monasca_notification.main Received signal 17, beginning graceful shutdown.',
                                      '@version' => '1',
                                      '@timestamp' => '2015-08-13T08:37:00.287Z',
                                      'type' => expected_application_type,
                                      'service' => 'notification',
                                      'host' => 'monasca',
                                      'path' => '/var/log/monasca/notification/notification.log'}) }

  let (:shutdown_event) { LogStash::SHUTDOWN }

  let (:simple_config) { {'monasca_log_api' => 'http://192.168.10.4:8080',
      'keystone_api' => 'http://192.168.10.5:5000',
      'domain_id' => 'abadcf984cf7401e88579d393317b0d9',
      'username' => 'username',
      'password' => 'password',
      'project_name' => 'project_name'} }

  let (:token_id) { LogStash::Outputs::Keystone::Token.new('abc', DateTime.now + Rational(5, 1440)) }

  let (:old_token_id) { LogStash::Outputs::Keystone::Token.new('def', DateTime.now - Rational(5, 1440)) }

  context 'when initializing' do
    it 'then it should register without exceptions' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api').new(simple_config)
      allow(monasca_log_api).to receive(:get_token).and_return(token_id)
      expect {monasca_log_api.register}.to_not raise_error
    end

    it "should set a default application_type_key to \"type\"" do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api').new(simple_config)
      expect(monasca_log_api.instance_variable_get('@application_type_key')).to eq("type")
    end

    it 'should use passed variable from config as application_type_key' do
      expected_key = 'mountain_dew'
      simple_config_copy = simple_config.clone
      simple_config_copy['application_type_key'] = expected_key
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api').new(simple_config_copy)

      expect(monasca_log_api.instance_variable_get('@application_type_key')).to eq(expected_key)
    end

  end

  context 'when receiving messages' do
    it 'then it should be send to monasca-log-api' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient).to receive(:send_event)
        .with(event, event.to_hash.to_json, token_id.id, nil, expected_application_type)
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(simple_config)

      allow(monasca_log_api).to receive(:get_token).and_return(token_id)
      allow(monasca_log_api).to receive(:get_application_type).and_call_original

      monasca_log_api.register
      monasca_log_api.receive(event)
    end

    it 'then it should check the token_id and renew it when its deprecated' do
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient).to receive(:authenticate)
        .with(simple_config['domain_id'], simple_config['username'], simple_config['password'], simple_config['project_name'])
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(simple_config)
      allow(monasca_log_api).to receive(:get_token).and_return(old_token_id)
      monasca_log_api.register
      allow(monasca_log_api).to receive(:get_token).and_call_original
      allow(monasca_log_api).to receive(:send_event)
      monasca_log_api.receive(event)
    end
  end

  context 'when given dictionary as type in received message' do
    it 'should read application_type from it properly' do
      type_dict = {
          "application_type" => 'notification'
      }
      config = simple_config.merge({"application_type_key" => 'type.application_type'})

      event = LogStash::Event.new({"message" => '2015-08-13 08:36:59,316 INFO monasca_notification.main Received signal 17, beginning graceful shutdown.',
                                   "@version" => '1',
                                   "@timestamp" => '2015-08-13T08:37:00.287Z',
                                   "type" => type_dict,
                                   "service" => 'notification',
                                   "host" => 'monasca',
                                   "path" => '/var/log/monasca/notification/notification.log',
                                  })
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient).to receive(:send_event)
        .with(event, event.to_hash.to_json, token_id.id, nil, expected_application_type)
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(config)

      allow(monasca_log_api).to receive(:get_token).and_return(token_id)
      allow(monasca_log_api).to receive(:get_application_type).and_call_original

      monasca_log_api.register
      monasca_log_api.receive(event)
    end

  end

  context 'when receiving SHUTDOWN message' do
    it 'then it should be send to monasca-log-api' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient).to_not receive(:send_event)
        .with(shutdown_event, nil, token_id.id, nil)
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(simple_config)
      allow(monasca_log_api).to receive(:get_token).and_return(token_id)
      monasca_log_api.register
      monasca_log_api.receive(shutdown_event)
    end
  end

end
