require 'helper'
require 'fluent/test/driver/filter'
require 'fluent/plugin/filter_maskrx'

class MaskRxFilterTest < Test::Unit::TestCase
  CONFIG = %[
    <mask>
      pattern /password=([.[^ ]]+)(?: |$)/
      mask    xxxxx
    </mask>
    <mask>
      keys token, accesskey
      pattern /^.+$/
    </mask>
  ]

  def setup
    omit_unless(Fluent.const_defined?(:Filter))
    Fluent::Test.setup
    @time = Fluent::Engine.now

    @filtered = filter([{
      "ident"     => "foo",
      "message"   => "Loop iteration 5488, example password=th!s1sap@$$w0rd and it should be masked.",
      "password"  => "password=th!s1sap@$$w0rd",
      "token"     => "this-is-a-token",
      "accesskey" => "this-is-an-access_key"
    }]).first
  end

  def create_driver(conf=CONFIG)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::MaskRxFilter).configure(conf)
  end

  def filter(messages, conf=CONFIG)
    d = create_driver(conf)

    d.run(default_tag: 'test', start: true, shutdown: false) do
      messages.each do |message|
        d.feed(message)
      end
    end

    d.filtered_records
  end

  sub_test_case 'configuration' do
    test 'empty config' do
      assert_raise(Fluent::ConfigError) do
        create_driver('')
      end
    end
  end

  sub_test_case 'masking' do
    test 'without keys' do
      assert_equal 'password=xxxxx', @filtered["password"]

      assert_equal \
        'Loop iteration 5488, example password=xxxxx and it should be masked.', \
        @filtered["message"]
    end

    test 'with keys' do
      assert_equal '********', @filtered["token"]
      assert_equal '********', @filtered["accesskey"]
    end
  end
end
