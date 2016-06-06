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

require_relative 'spec_helper'

describe 'outputs/monasca_log_api' do

  let (:event) { LogStash::Event.new(
    {
      'message' => '2015-08-13 08:36:59,316 INFO monasca_notification '\
      'graceful shutdown.',
      '@version' => '1',
      '@timestamp' => '2015-08-13T08:37:00.287Z',
      'path' => '/opt/logstash-2.2.0/test.log',
      'host' => 'monasca',
      'type' => 'test-type',
      'tags' => ['test-service', 'high']
    })
  }

  let (:long_event) { LogStash::Event.new(
    {
      'message' => 'A veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeery loooooooooooooooooooooooooooooooooooooooooong messsssssssssssssss'\
      'sssssssssssssssssage ...... A veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeeeeeeeeeeeeeeeeery loooooooooooooooooooooooooooooooooooooooooong mess'\
      'ssssssssssssssssssssssssssssssssage ...... A veeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery loooooooooooooooooooooooooooooooooo'\
      'oooooooong messssssssssssssssssssssssssssssssssage ..... A veeeeeeeeeee'\
      'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery loooooooooooooooooooo'\
      'oooooooooooooooooooooong messssssssssssssssssssssssssssssssssage ..... '\
      'A veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery loooooo'\
      'oooooooooooooooooooooooooooooooooooong messssssssssssssssssssssssssssss'\
      'ssssage ..... A veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeeery loooooooooooooooooooooooooooooooooooooooooong messssssssssssssss'\
      'ssssssssssssssssssage ..... A veeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeeeeeeeeeeeeeeeeery loooooooooooooooooooooooooooooooooooooooooong mess'\
      'ssssssssssssssssssssssssssssssssage ..... A veeeeeeeeeeeeeeeeeeeeeeeeee'\
      'eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeery looooooooooooooooooooooooooooooooooo'\
      'ooooooong messssssssssssssssssssssssssssssssssage .....  2015-08-13 08:'\
      '36:59,316 INFO monasca_notification.main Received signal 17, beginning '\
      'graceful shutdown.',
      '@version' => '1',
      '@timestamp' => '2015-08-13T08:37:00.287Z',
      'path' => '/opt/logstash-2.2.0/test.log',
      'host' => 'monasca',
      'type' => 'test-type',
      'dimensions' => '["[\"service\", \"nova\"]", "[\"priority\", \"high\"]"]',
      'tags' => ['test-service', 'high']
    })
  }

  let (:event_without_dims) { LogStash::Event.new(
    {
      'message' => 'A graceful shutdown.',
      '@version' => '1',
      '@timestamp' => '2015-08-13T08:37:00.287Z',
      'path' => '/opt/logstash-2.2.0/test.log',
      'host' => 'monasca',
      'type' => 'test-type',
      'tags' => ['test-service', 'high']
    })
  }

  let (:event_with_one_dim) { LogStash::Event.new(
    {
      'message' => 'A graceful shutdown.',
      '@version' => '1',
      '@timestamp' => '2015-08-13T08:37:00.287Z',
      'path' => '/opt/logstash-2.2.0/test.log',
      'host' => 'monasca',
      'type' => 'test-type',
      'dimensions' => '["service", "nova"]',
      'tags' => ['test-service', 'high']
    })
  }

  let (:event_with_more_dims) { LogStash::Event.new(
    {
      'message' => 'A graceful shutdown.',
      '@version' => '1',
      '@timestamp' => '2015-08-13T08:37:00.287Z',
      'path' => '/opt/logstash-2.2.0/test.log',
      'host' => 'monasca',
      'type' => 'test-type',
      'dimensions' => '["[\"service\", \"nova\"]", "[\"priority\", \"high\"]"]',
      'tags' => ['test-service', 'high']
    })
  }

  let (:project_name) { 'monasca' }
  let (:username) { 'operator' }
  let (:password) { 'qweqwe' }

  let (:monasca_log_api_url) { 'http://192.168.10.4:5607/v3.0' }
  let (:keystone_api_url) { 'http://192.168.10.5:5000/v3' }

  let (:complete_config) {
    {
      'monasca_log_api_url' => monasca_log_api_url,
      'monasca_log_api_insecure' => false,
      'keystone_api_url' => keystone_api_url,
      'keystone_api_insecure' => false,
      'project_name' => project_name,
      'username' => username,
      'password' => password,
      'domain_id' => 'abadcf984cf7401e88579d393317b0d9',
      'dimensions' => ['service:test'],
      'num_of_logs' => 3,
      'elapsed_time_sec' => 5000,
      'delay' => 1,
      'max_data_size_kb' => 4
    }
  }

  let (:complete_config_short_elapsed_time) {
    {
      'monasca_log_api_url' => monasca_log_api_url,
      'monasca_log_api_insecure' => false,
      'keystone_api_url' => keystone_api_url,
      'keystone_api_insecure' => false,
      'project_name' => project_name,
      'username' => username,
      'password' => password,
      'domain_id' => 'abadcf984cf7401e88579d393317b0d9',
      'dimensions' => ['service:test'],
      'num_of_logs' => 3,
      'elapsed_time_sec' => 1,
      'delay' => 1,
      'max_data_size_kb' => 4
    }
  }

  let (:simple_config) {
    {
      'monasca_log_api_url' => monasca_log_api_url,
      'keystone_api_url' => keystone_api_url,
      'project_name' => project_name,
      'username' => username,
      'password' => password,
      'domain_id' => 'abadcf984cf7401e88579d393317b0d9',
    }
  }

  let (:config_negative) {
    {
      'monasca_log_api_url' => monasca_log_api_url,
      'keystone_api_url' => keystone_api_url,
      'project_name' => project_name,
      'username' => username,
      'password' => password,
      'domain_id' => 'abadcf984cf7401e88579d393317b0d9',
      'num_of_logs' => rand(-999_999..-1),
      'elapsed_time_sec' => rand(-999_999..-1),
      'delay' => rand(-999_999..-1),
      'max_data_size_kb' => rand(-999_999..-1),
    }
  }

  let (:empty_config) { {} }

  let (:valid_date) { DateTime.now + Rational(5, 1440) }
  let (:expired_date) { DateTime.now - Rational(5, 1440) }
  let (:token_id) { "f8cdafb7dce94444ad781a53ddaff693" }
  let (:old_token_id) { "553ae6ea7d074f00a12750e4aa1dad50" }

  let (:valid_token) { {:token => token_id,
    :expires_at => valid_date } }

  let (:expired_token) { {:token => old_token_id,
    :expires_at => expired_date } }

  after(:each) do
    token = LogStash::Outputs::Keystone::Token.instance
    token.set_token nil, nil
  end

  context 'when initializing' do

    it 'without configuration, then raise error' do
      expect {LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(empty_config)}.to raise_error(LogStash::ConfigurationError)
    end

    it 'with minimal configuration, then use defaults' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(simple_config)

      expect(monasca_log_api.monasca_log_api_insecure).to be_falsey
      expect(monasca_log_api.dimensions).to be_nil
      expect(monasca_log_api.num_of_logs).to be_instance_of(Fixnum)
      expect(monasca_log_api.elapsed_time_sec).to be_instance_of(Fixnum)
      expect(monasca_log_api.delay).to be_instance_of(Fixnum)
      expect(monasca_log_api.max_data_size_kb).to be_instance_of(Fixnum)
    end

    it 'with complete configuration, then override settings' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)

      expect(monasca_log_api.monasca_log_api_insecure)
        .to eq(complete_config['monasca_log_api_insecure'])
      expect(monasca_log_api.dimensions).to eq(complete_config['dimensions'])
      expect(monasca_log_api.num_of_logs).to eq(complete_config['num_of_logs'])
      expect(monasca_log_api.elapsed_time_sec)
        .to eq(complete_config['elapsed_time_sec'])
      expect(monasca_log_api.delay).to eq(complete_config['delay'])
      expect(monasca_log_api.max_data_size_kb)
        .to eq(complete_config['max_data_size_kb'])
    end

    it 'with negative numbers in configuration, then raise error' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(config_negative)

      expect { monasca_log_api.register }
        .to raise_error(LogStash::ConfigurationError), config_negative.to_s
    end
  end

  context 'when registering' do
    it 'should initialize the token' do
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      allow(monasca_log_api).to receive(:start_time_check)
      expect {monasca_log_api.register}.to_not raise_error
      expect(LogStash::Outputs::Keystone::Token.instance.id).not_to be_nil
    end

    it 'should start time check thread' do
      expect_any_instance_of(LogStash::Outputs::MonascaLogApi)
        .to receive(:start_time_check)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      allow(monasca_log_api).to receive(:init_token)
      expect {monasca_log_api.register}.to_not raise_error
    end
  end

  context 'initialize log body' do
    it 'with dimensions' do
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      monasca_log_api.register
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'])
        .not_to be_nil
      expect(monasca_log_api.instance_variable_get(:@logs)['dimensions'])
        .not_to be_nil
      expect(monasca_log_api.instance_variable_get(:@logs)['dimensions'])
        .not_to be_empty
    end

    it 'without dimensions' do
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(simple_config)
      monasca_log_api.register
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'])
        .not_to be_nil
      expect(monasca_log_api.instance_variable_get(:@logs)['dimensions'])
        .to be_nil
    end
  end

  context 'when receiving messages' do
    it 'collect messages' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to_not receive(:send_logs)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(0)
      monasca_log_api.multi_receive([event])
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(1)
      monasca_log_api.multi_receive([event])
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(2)
    end

    it 'collect messages up to certain amount and send logs' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to receive(:send_logs)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([event])
      monasca_log_api.multi_receive([event])
      monasca_log_api.multi_receive([event])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(0)
    end

    it 'collect messages up to certain bytesize and send logs' do

      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to receive(:send_logs)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([long_event, long_event])
      monasca_log_api.multi_receive([long_event])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(1)
    end

    it 'sends logs after a specific time' do

      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to receive(:send_logs)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config_short_elapsed_time)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)

      monasca_log_api.register
      monasca_log_api.multi_receive([event])

      sleep(3)

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(0)
    end
  end

  context 'when parsing events' do
    it 'without dimensions' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([event_without_dims])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'])
        .to eq([{"message"=>"A graceful shutdown.",
          "dimensions"=>{"path"=>"/opt/logstash-2.2.0/test.log",
            "type"=>"test-type"}}])
    end

    it 'with one dimensions' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([event_with_one_dim])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'])
        .to eq([{"message"=>"A graceful shutdown.",
          "dimensions"=>{"path"=>"/opt/logstash-2.2.0/test.log",
            "type"=>"test-type", "service"=>"nova"}}])
    end

    it 'with more dimensions' do
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([event_with_more_dims])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'])
        .to eq([{"message"=>"A graceful shutdown.",
          "dimensions"=>{"path"=>"/opt/logstash-2.2.0/test.log",
            "type"=>"test-type", "service"=>"nova", "priority"=>"high"}}])
    end
  end

  context 'after sending logs' do
    it 'clears collected logs' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to receive(:send_logs)
      monasca_log_api = LogStash::Plugin.lookup('output', 'monasca_log_api')
        .new(complete_config)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).and_return(valid_token)
      allow(monasca_log_api).to receive(:start_time_check)

      monasca_log_api.register
      monasca_log_api.multi_receive([event])
      monasca_log_api.multi_receive([event])
      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(2)
      monasca_log_api.multi_receive([event])

      expect(monasca_log_api.instance_variable_get(:@logs)['logs'].size)
        .to eq(0)
    end
  end

  context 'check token' do
    it 'if expired, renew it' do
      expect_any_instance_of(LogStash::Outputs::Monasca::MonascaLogApiClient)
        .to receive(:send_logs)
      expect_any_instance_of(LogStash::Outputs::Keystone::KeystoneClient)
        .to receive(:authenticate).with(complete_config['domain_id'],
          complete_config['username'],
          complete_config['password'],
          complete_config['project_name'])
        .and_return(expired_token, valid_token)
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(complete_config)
      allow(monasca_log_api).to receive(:start_time_check)
      monasca_log_api.register
      expect(LogStash::Outputs::Keystone::Token.instance.id).to eq(old_token_id)
      monasca_log_api.multi_receive([event, event, event])
      expect(LogStash::Outputs::Keystone::Token.instance.id).to eq(token_id)
    end
  end

  context 'when stopping plugin' do
    it 'then it should kill time thread' do
      expect_any_instance_of(Thread).to receive(:kill)
      monasca_log_api = LogStash::Outputs::MonascaLogApi.new(simple_config)
      allow(monasca_log_api).to receive(:init_token)
      monasca_log_api.register
      monasca_log_api.close
    end
  end

end
