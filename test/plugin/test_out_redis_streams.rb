require "helper"
require "fluent/plugin/out_redis_streams.rb"

class RedisStreamsOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RedisStreamsOutput).configure(conf)
  end
end
