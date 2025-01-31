#
# Copyright 2025- TODO: Write your name
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/plugin/output"

module Fluent
  module Plugin
    class RedisStreamsOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("redis_streams", self)
      attr_reader :host, :port, :channel, :redis
      def initialize
        super
        require 'redis'
        require 'msgpack'
      end
  
      def configure(config)
        super
        @host    = config.has_key?('host')    ? config['host']         : 'localhost'
        @port    = config.has_key?('port')    ? config['port'].to_i    : 6379
        raise Fluent::ConfigError, "need channel" if not config.has_key?('channel') or config['channel'].empty?
        @channel = config['channel'].to_s
      end
  
      def start
        super
        @redis = Redis.new(:host => @host, :port => @port ,:thread_safe => true)
      end
  
      def shutdown
        @redis.quit
      end
  
      def format(tag, time, record)
        record['__tag__']  = tag
        record['__time__'] = time
        record.to_msgpack
      end
  
      def write(chunk)
        @redis.pipelined do
          chunk.msgpack_each do |record|
            @redis.streams @channel, record.to_json
          end
        end
      end
    end
  end
end
